package com.cookshare.backend.service;

import com.cookshare.backend.dto.RecipeDTO;
import com.cookshare.backend.dto.RecipeIngredientDTO;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.genai.Client;
import com.google.genai.types.Blob;
import com.google.genai.types.Content;
import com.google.genai.types.GenerateContentResponse;
import com.google.genai.types.Part;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
public class GeminiService {

    private final ObjectMapper objectMapper;

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.model}")
    private String model;

    public GeminiService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public RecipeDTO extractRecipeFromVideo(MultipartFile videoFile) throws IOException {
        if (apiKey == null || apiKey.isBlank() || apiKey.startsWith("${")) {
            throw new RuntimeException(
                "La API key de Gemini no está configurada en application.properties. " +
                "Revisa la propiedad 'gemini.api.key'.");
        }

        String prompt = """
                Analiza este vídeo de cocina y extrae la receta completa.
                Responde ÚNICAMENTE con un JSON válido, sin texto adicional, con esta estructura exacta:
                {
                  "title": "nombre de la receta",
                  "description": "descripción breve de la receta",
                  "instructions": "instrucciones paso a paso separadas por saltos de línea",
                  "servingsBase": número de raciones,
                  "ingredients": [
                    {
                      "ingredientName": "nombre del ingrediente",
                      "quantity": cantidad numérica,
                      "unit": "unidad de medida"
                    }
                  ]
                }
                Si no puedes identificar una cantidad exacta, usa 0.
                Si no puedes identificar la unidad, usa "al gusto".
                """;

        try {
            Client client = Client.builder()
                    .apiKey(apiKey)
                    .build();

            String mimeType = videoFile.getContentType();
            // Fallback: application/octet-stream es genérico y Gemini lo rechaza
            if (mimeType == null || mimeType.equals("application/octet-stream")) {
                String filename = videoFile.getOriginalFilename();
                if (filename != null) {
                    String ext = filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();
                    mimeType = switch (ext) {
                        case "mp4"  -> "video/mp4";
                        case "mov"  -> "video/quicktime";
                        case "avi"  -> "video/x-msvideo";
                        case "webm" -> "video/webm";
                        default     -> "video/mp4";
                    };
                } else {
                    mimeType = "video/mp4";
                }
            }
            byte[] videoBytes = videoFile.getBytes();

            GenerateContentResponse response = client.models.generateContent(
                    model,
                    List.of(
                            Content.builder()
                                    .parts(List.of(
                                            Part.builder()
                                                    .inlineData(Blob.builder()
                                                            .mimeType(mimeType)
                                                            .data(videoBytes)
                                                            .build())
                                                    .build(),
                                            Part.builder()
                                                    .text(prompt)
                                                    .build()
                                    ))
                                    .build()
                    ),
                    null
            );

            String text = response.text();
            return parseGeminiResponse(text);

        } catch (Exception e) {
            System.err.println("[GeminiService] Error llamando a Gemini: " + e.getMessage());
            String msg = e.getMessage() != null ? e.getMessage() : "";
            if (msg.contains("429") || msg.contains("Too Many Requests") || msg.contains("RESOURCE_EXHAUSTED")) {
                throw new RuntimeException(
                        "Has alcanzado el límite de peticiones a Gemini. " +
                        "Espera unos minutos e inténtalo de nuevo.", e);
            }
            if (msg.contains("401") || msg.contains("403") || msg.contains("API_KEY") || msg.contains("API key")) {
                throw new RuntimeException(
                        "Problema de autenticación con Gemini. Revisa la API key.", e);
            }
            throw new RuntimeException("Error al contactar con Gemini: " + msg, e);
        }
    }

    private RecipeDTO parseGeminiResponse(String text) {
        try {
            // Gemini a veces envuelve el JSON en backticks de markdown
            text = text.replace("```json", "").replace("```", "").trim();

            JsonNode recipeNode = objectMapper.readTree(text);

            RecipeDTO dto = new RecipeDTO();
            dto.setTitle(recipeNode.path("title").asText());
            dto.setDescription(recipeNode.path("description").asText());
            dto.setInstructions(recipeNode.path("instructions").asText());
            dto.setServingsBase(recipeNode.path("servingsBase").asInt(4));
            dto.setIsPublic(false);

            List<RecipeIngredientDTO> ingredients = new ArrayList<>();
            JsonNode ingredientsNode = recipeNode.path("ingredients");
            if (ingredientsNode.isArray()) {
                for (JsonNode ingNode : ingredientsNode) {
                    RecipeIngredientDTO ingDTO = new RecipeIngredientDTO();
                    ingDTO.setIngredientName(ingNode.path("ingredientName").asText());
                    ingDTO.setQuantity(BigDecimal.valueOf(ingNode.path("quantity").asDouble()));
                    ingDTO.setUnit(ingNode.path("unit").asText());
                    ingredients.add(ingDTO);
                }
            }
            dto.setRecipeIngredients(ingredients);

            return dto;

        } catch (Exception e) {
            throw new RuntimeException("Error al parsear la respuesta de Gemini: " + e.getMessage());
        }
    }
}
