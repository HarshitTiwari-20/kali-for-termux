#!/data/data/com.termux/files/usr/bin/bash
# Modern Kali Linux Installer for Termux (2025) - Uses official Kali Rolling
# Works on Android 7+ | No root needed | PRoot-based

clear
echo
echo -e "\e[1;35m╔═╗┌─┐┬  ┬    ┬  ┬┌┐┌┬  ┬┌┐┌┬┌┐┌┌─┐\e[0m"
echo -e "\e[1;35m╚═╗├─┤└┐┌┘    └┐┌┘├┴┘└┐┌┘├┴┐│││││ ┬\e[0m"
echo -e "\e[1;35m╚═╝┴ ┴ └┘      └┘ └┘   └┘ └┘└┘└┘└┘└─┘\e[0m"
echo -e "\e[1;37m          Kali Linux Rolling for Termux (2025)\e[0m"
echo

time1=$(date +"%I:%M %p")

# Colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
C="\e[36m"
P="\e[35m"
W="\e[0m"

# Check prerequisites
check_deps() {
  for cmd in proot wget tar termux-setup-storage; do
    if ! command -v "$cmd" >/dev/null; then
      echo -e "[$time1] ${R}[ERROR]${W} Please install $cmd first:"
      echo -e "        pkg install $cmd -y"
      exit 1
    fi
  done
}

install_kali() {
  directory="kali-fs"
  bind_dir="kali-binds"
  launcher="start-kali.sh"

  if [ -d "$directory" ]; then
    echo -e "[$time1] ${Y}[WARNING]${W} Kali directory already exists. Skipping download."
    echo -e "          To reinstall, delete '$directory' folder first.\n"
  else
    echo -e "[$time1] ${G}[INFO]${W} Detecting architecture..."
    arch=$(dpkg --print-architecture)
    case $arch in
    aarch64 | arm64) kali_arch="arm64" ;;
    arm*) kali_arch="armhf" ;;
    amd64 | x86_64) kali_arch="amd64" ;;
    i*86) kali_arch="i386" ;;
    *)
      echo -e "[$time1] ${R}[ERROR]${W} Unsupported architecture: $arch"
      exit 1
      ;;
    esac

    echo -e "[$time1] ${G}[INFO]${W} Downloading Kali Linux Rolling ($kali_arch)..."
    wget -q --show-progress \
      "https://kali.download/nethunter-images/current/rootfs/kalifs-$kali_arch-full.tar.xz" \
      -O kali.tar.xz || {
      echo -e "[$time1] ${R}[ERROR]${W} Download failed. Trying mirror..."
      wget -q --show-progress \
        "http://http.kali.org/kali/pool/main/k/kali-rootfs/kalifs-$kali_arch-full.tar.xz" \
        -O kali.tar.xz || exit 1
    }

    echo -e "[$time1] ${G}[INFO]${W} Extracting Kali rootfs (this may take 3-10 minutes)..."
    mkdir -p $directory
    tar -xJf kali.tar.xz -C $directory --exclude='dev' || exit 1
    rm kali.tar.xz

    # Fix DNS
    echo "nameserver 8.8.8.8" >$directory/etc/resolv.conf

    echo -e "[$time1] ${G}[INFO]${W} Kali rootfs installed successfully!"
  fi

  # Create bind directory
  mkdir -p $bind_dir

  # Create launcher script
  echo -e "[$time1] ${G}[INFO]${W} Creating start script: $launcher"
  cat >$launcher <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd $(dirname $0)

# Unset conflicting variables
unset LD_PRELOAD

# Build proot command
cmd="proot"
cmd+=" --link2symlink"
cmd+=" -0"                       # Fake root
cmd+=" -r kali-fs"
cmd+=" -b /dev"
cmd+=" -b /proc"
cmd+=" -b /sys"
cmd+=" -b /sdcard"
cmd+=" -b /storage"
cmd+=" -b /data/data/com.termux/files/home:/root"
cmd+=" -b /data/data/com.termux"
cmd+=" -b /:/host-rootfs"
cmd+=" -w /root"
cmd+=" /usr/bin/env -i"
cmd+=" HOME=/root"
cmd+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin"
cmd+=" TERM=xterm-256color"
cmd+=" /bin/bash --login"

# Execute
if [ $# -eq 0 ]; then
    exec $cmd
else
    $cmd -c "$@"
fi
EOF

  chmod +x $launcher
  termux-fix-shebang $launcher 2>/dev/null || true

  echo
  echo -e "${G}╔══════════════════════════════════════════════════════════╗${W}"
  echo -e "${G}║                KALI LINUX INSTALLED SUCCESSFULLY!        ║${W}"
  echo -e "${G}╚══════════════════════════════════════════════════════════╝${W}"
  echo
  echo -e "   ${C}To start Kali Linux, run:${W}"
  echo -e "       \e[1;33m./$launcher\e[0m"
  echo
  echo -e "   ${Y}First time setup (recommended):${W}"
  echo -e "       ${W}./$launcher${W}   → then inside Kali:"
  echo -e "           ${C}apt update && apt full-upgrade -y${W}"
  echo -e "           ${C}apt install kali-linux-headless${W}   (or kali-linux-default)"
  echo
  echo -e "   ${P}Enjoy offensive security on the go!${W} 🔴"
  echo
}

# Main
check_deps

if [[ "$1" == "-y" ]] || [[ "$1" == "--yes" ]]; then
  install_kali
else
  echo -e "[$time1] ${C}[?]${W} Install Kali Linux Rolling in Termux? (Y/n)"
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]] || [[ -z "$answer" ]]; then
    install_kali
  else
    echo -e "[$time1] ${R}[ABORTED]${W} Installation cancelled."
    exit 0
  fi
fi
