# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # ── Box base: Debian 13 "Trixie" ─────────────────────────────────────────────
  config.vm.box = "debian/trixie64"

  # ── Puertos: VM → anfitrión ──────────────────────────────────────────────────
  config.vm.network "forwarded_port", guest: 80,   host: 80    # Frontend CookShare
  config.vm.network "forwarded_port", guest: 9443, host: 9443  # Portainer CE

  # ── Recursos VirtualBox ──────────────────────────────────────────────────────
  config.vm.provider "virtualbox" do |vb|
    vb.name   = "cookshare-vm"
    vb.memory = 4096   # Flutter build necesita memoria; 4 GB es cómodo
    vb.cpus   = 2
  end

  # ── Aprovisionamiento (se ejecuta la primera vez con `vagrant up`) ────────────
  config.vm.provision "shell", inline: <<-SHELL
    set -e

    echo "==> [1/5] Actualizando paquetes base e instalando dependencias..."
    apt-get update -qq
    apt-get install -y -qq ca-certificates curl gnupg git

    echo "==> [2/5] Instalando Docker Engine desde el repositorio oficial..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
      | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update -qq
    apt-get install -y -qq \
      docker-ce docker-ce-cli containerd.io \
      docker-buildx-plugin docker-compose-plugin

    systemctl enable docker
    systemctl start docker
    usermod -aG docker vagrant

    echo "==> [3/5] Instalando Portainer CE (puerto 9443)..."
    docker volume create portainer_data
    docker run -d \
      --name=portainer \
      --restart=always \
      -p 9443:9443 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      portainer/portainer-ce:latest

    echo "==> [4/5] Clonando proyecto en /opt/cookshare (fuera de /vagrant)..."
    git clone https://github.com/NoeliaFreire04/proyecto-dam.git /opt/cookshare

    # Creamos el .env con los valores por defecto.
    # Para usar la funcionalidad de IA, edita GEMINI_API_KEY y haz:
    #   docker compose -f /opt/cookshare/docker-compose.yml restart backend
    cat > /opt/cookshare/.env << 'EOF'
GEMINI_API_KEY=
JWT_SECRET=c29va2NoYXJlU2VjcmV0S2V5UGFyYUxhQXBsaWNhY2lvbkNvb2tTaGFyZTIwMjU=
MYSQL_ROOT_PASSWORD=abc123.
EOF

    echo "==> [5/5] Levantando stack completo (db + backend + frontend)..."
    cd /opt/cookshare
    docker compose up -d --build

    echo ""
    echo "========================================================"
    echo "  CookShare desplegado correctamente."
    echo ""
    echo "  Frontend  →  http://localhost"
    echo "  Portainer →  https://localhost:9443"
    echo "              (acepta el certificado autofirmado)"
    echo ""
    echo "  NOTA: si quieres usar Gemini (análisis de vídeo):"
    echo "    1. vagrant ssh"
    echo "    2. nano /opt/cookshare/.env  → añade tu GEMINI_API_KEY"
    echo "    3. cd /opt/cookshare && docker compose restart backend"
    echo "========================================================"
  SHELL

end
