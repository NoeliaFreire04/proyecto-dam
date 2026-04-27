package com.cookshare.backend.service;

import com.cookshare.backend.dto.RecipeDTO;
import com.cookshare.backend.dto.RecipeIngredientDTO;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.client.WebClient;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.Map;

/**
 * Servicio de integración con Google Gemini.
 * Recibe un vídeo de cocina, lo envía al modelo y parsea
 * la respuesta para crear una receta estructurada.
 */
@Service
public class GeminiService {

    private final WebClient webClient;
    private final ObjectMapper objectMapper;

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.model}")
    private String model;

    /**
     * Constructor que configura el WebClient con la URL base de Gemini.
     *
     * @param apiUrl URL base de la API de Gemini
     * @param objectMapper mapper JSON de Spring
     */
    public GeminiService(@Value("${gemini.api.url}") String apiUrl,
                         ObjectMapper objectMapper) {
        this.webClient = WebClient.builder()
                .baseUrl(apiUrl)
                .build();
        this.objectMapper = objectMapper;
    }

    /**
     * Extrae una receta de un archivo de vídeo usando Google Gemini.
     * Codifica el vídeo en base64, lo envía con un prompt estructurado
     * y parsea la respuesta JSON en un RecipeDTO.
     *
     * @param videoFile archivo de vídeo subido por el usuario
     * @return RecipeDTO con los datos extraídos del vídeo
     * @throws IOException si hay error al leer el archivo
     */
    public RecipeDTO extractRecipeFromVideo(MultipartFile videoFile) throws IOException {
        String base64Video = Base64.getEncoder().encodeToString(videoFile.getBytes());
        String mimeType = videoFile.getContentType();

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

        // Monta el cuerpo de la petición con el formato que espera Gemini
        Map<String, Object> requestBody = Map.of(
                "contents", List.of(
                        Map.of("parts", List.of(
                                Map.of("inline_data", Map.of(
                                        "mime_type", mimeType,
                                        "data", base64Video
                                )),
                                Map.of("text", prompt)
                        ))
                )
        );

        String requestJson = objectMapper.writeValueAsString(requestBody);

        // Llama a la API de Gemini
        String response = webClient.post()
                .uri("/models/{model}:generateContent?key={key}", model, apiKey)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(requestJson)
                .retrieve()
                .bodyToMono(String.class)
                .block();

        return parseGeminiResponse(response);
    }

    /**
     * Parsea la respuesta de Gemini y extrae el RecipeDTO.
     * La respuesta viene en candidates[0].content.parts[0].text como JSON.
     *
     * @param response respuesta raw de la API
     * @return RecipeDTO con los datos extraídos
     */
    private RecipeDTO parseGeminiResponse(String response) {
        try {
            JsonNode root = objectMapper.readTree(response);
            String text = root.path("candidates").get(0)
                    .path("content").path("parts").get(0)
                    .path("text").asText();

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