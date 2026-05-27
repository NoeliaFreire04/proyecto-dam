# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # ── Box base: Debian 13 "Trixie" ─────────────────────────────────────────────
  config.vm.box = "bento/debian-13"

  # ── Puertos: VM → anfitrión ──────────────────────────────────────────────────
  config.vm.network "forwarded_port", guest: 80,   host: 8090  # Frontend CookShare
  config.vm.network "forwarded_port", guest: 9443, host: 9443  # Portainer CE

  # Aumentamos el timeout de boot (el primer arranque puede ser lento)
  config.vm.boot_timeout = 600

  # ── Recursos VirtualBox ──────────────────────────────────────────────────────
  config.vm.provider "virtualbox" do |vb|
    vb.name   = "cookshare-vm"
    vb.memory = 4096   # Flutter build necesita memoria; 4 GB es cómodo
    vb.cpus   = 2
    vb.gui    = true   # Mostrar ventana VirtualBox para ver el arranque
  end

  # ── Aprovisionamiento (se ejecuta la primera vez con `vagrant up`) ────────────
  config.vm.provision "shell", inline: <<-'SHELL'

    set -eux

    # ── 1. Paquetes base ────────────────────────────────────────────────────────
    echo "==> [1/5] Actualizando paquetes base..."
    apt-get update -qq
    apt-get install -y -qq ca-certificates curl gnupg git

    # ── 2. Docker Engine ────────────────────────────────────────────────────────
    echo "==> [2/5] Instalando Docker Engine..."

    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg \
      -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Obtenemos arquitectura y codename por separado para evitar problemas
    # con comillas anidadas dentro del echo.
    ARCH=$(dpkg --print-architecture)
    CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")

    # Si Docker todavía no publica paquetes para trixie usamos bookworm
    # (Debian 12), que es 100% compatible en binarios.
    DOCKER_DIST="$CODENAME"
    curl -fsSL "https://download.docker.com/linux/debian/dists/${DOCKER_DIST}/Release" \
      -o /dev/null 2>&1 \
      || DOCKER_DIST="bookworm"

    echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/debian ${DOCKER_DIST} stable" \
      > /etc/apt/sources.list.d/docker.list

    apt-get update -qq
    apt-get install -y -qq \
      docker-ce docker-ce-cli containerd.io \
      docker-buildx-plugin docker-compose-plugin

    systemctl enable docker
    systemctl start docker
    usermod -aG docker vagrant

    # ── 3. Portainer CE ─────────────────────────────────────────────────────────
    echo "==> [3/5] Instalando Portainer CE (puerto 9443)..."
    docker volume create portainer_data
    docker run -d \
      --name=portainer \
      --restart=always \
      -p 9443:9443 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      portainer/portainer-ce:latest

    # ── 4. Clonar proyecto ──────────────────────────────────────────────────────
    echo "==> [4/5] Clonando proyecto en /opt/cookshare..."
    git clone https://github.com/NoeliaFreire04/proyecto-dam.git /opt/cookshare

    cat > /opt/cookshare/.env <<'EOF'
GEMINI_API_KEY=
JWT_SECRET=c29va2NoYXJlU2VjcmV0S2V5UGFyYUxhQXBsaWNhY2lvbkNvb2tTaGFyZTIwMjU=
MYSQL_ROOT_PASSWORD=abc123.
EOF

    # ── 5. Levantar stack ───────────────────────────────────────────────────────
    echo "==> [5/5] Levantando stack completo (db + backend + frontend)..."
    cd /opt/cookshare
    docker compose up -d --build

    echo ""
    echo "========================================================"
    echo "  CookShare desplegado correctamente."
    echo ""
    echo "  Frontend  ->  http://localhost"
    echo "  Portainer ->  https://localhost:9443"
    echo "              (acepta el certificado autofirmado)"
    echo ""
    echo "  Para Gemini: vagrant ssh"
    echo "    nano /opt/cookshare/.env  (pon tu GEMINI_API_KEY)"
    echo "    cd /opt/cookshare && docker compose restart backend"
    echo "========================================================"

  SHELL

end
