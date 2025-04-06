#!/bin/bash

# Menu interactif pour lancer différentes commandes
# Auteur: Claude
# Date: $(date +%Y-%m-%d)

# Couleurs pour le terminal
ROUGE='\033[0;31m'
VERT='\033[0;32m'
BLEU='\033[0;34m'
JAUNE='\033[1;33m'
NC='\033[0m' # Pas de couleur

# Fonction pour afficher le titre
afficher_titre() {
    clear
    echo -e "${JAUNE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║             MENU INTERACTIF               ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Fonction pour afficher une séparation
separation() {
    echo -e "${BLEU}----------------------------------------${NC}"
}

# Fonction pour afficher le menu
afficher_menu() {
    afficher_titre
    echo -e "${VERT}Choisissez une option :${NC}"
    echo ""
    echo -e "${JAUNE}1.${NC} Informations système"
    echo -e "${JAUNE}2.${NC} Espace disque"
    echo -e "${JAUNE}3.${NC} Utilisateurs connectés"
    echo -e "${JAUNE}4.${NC} Les 5 processus les plus gourmands en CPU"
    echo -e "${JAUNE}5.${NC} Tester la connexion internet"
    echo -e "${JAUNE}6.${NC} Chercher un fichier"
    echo -e "${JAUNE}7.${NC} Voir les dernières lignes d'un fichier log"
    echo -e "${JAUNE}8.${NC} Vider le cache et libérer de la mémoire"
    echo -e "${ROUGE}0.${NC} Quitter"
    echo ""
    echo -n "Votre choix: "
}

# Fonction pour attendre que l'utilisateur appuie sur Entrée
attendre() {
    echo ""
    echo -e "${BLEU}Appuyez sur Entrée pour continuer...${NC}"
    read
}

# Fonction pour afficher les informations système
info_systeme() {
    separation
    echo -e "${VERT}INFORMATIONS SYSTÈME${NC}"
    separation
    echo -e "${JAUNE}Système d'exploitation:${NC}"
    uname -a
    echo ""
    echo -e "${JAUNE}Version du système:${NC}"
    if [ -f /etc/os-release ]; then
        cat /etc/os-release | grep "PRETTY_NAME" | cut -d "=" -f 2 | tr -d '"'
    elif [ -f /etc/lsb-release ]; then
        cat /etc/lsb-release | grep "DESCRIPTION" | cut -d "=" -f 2 | tr -d '"'
    else
        echo "Information non disponible"
    fi
    echo ""
    echo -e "${JAUNE}CPU:${NC}"
    lscpu | grep "Model name" | sed 's/Model name://' | sed 's/^[ \t]*//'
    echo ""
    echo -e "${JAUNE}Mémoire:${NC}"
    free -h | grep "Mem:" | awk '{print $2 " total, " $3 " utilisée, " $4 " libre"}'
}

# Fonction pour afficher l'espace disque
espace_disque() {
    separation
    echo -e "${VERT}ESPACE DISQUE${NC}"
    separation
    df -h | grep -v "tmpfs" | grep -v "udev"
}

# Fonction pour afficher les utilisateurs connectés
utilisateurs_connectes() {
    separation
    echo -e "${VERT}UTILISATEURS CONNECTÉS${NC}"
    separation
    who
}

# Fonction pour afficher les 5 processus les plus gourmands en CPU
top_processus() {
    separation
    echo -e "${VERT}TOP 5 PROCESSUS${NC}"
    separation
    ps aux --sort=-%cpu | head -n 6
}

# Fonction pour tester la connexion internet
tester_connexion() {
    separation
    echo -e "${VERT}TEST DE CONNEXION INTERNET${NC}"
    separation
    echo -e "${JAUNE}Ping vers google.com...${NC}"
    ping -c 4 google.com
}

# Fonction pour chercher un fichier
chercher_fichier() {
    separation
    echo -e "${VERT}RECHERCHE DE FICHIER${NC}"
    separation
    echo -n "Entrez le nom ou une partie du nom du fichier à chercher: "
    read nom_fichier
    echo -e "${JAUNE}Recherche en cours...${NC}"
    find $HOME -name "*$nom_fichier*" -type f 2>/dev/null
}

# Fonction pour voir les dernières lignes d'un fichier log
voir_log() {
    separation
    echo -e "${VERT}VISUALISATION DE FICHIER LOG${NC}"
    separation
    echo "Choisissez un fichier log à visualiser:"
    echo -e "${JAUNE}1.${NC} /var/log/syslog"
    echo -e "${JAUNE}2.${NC} /var/log/auth.log"
    echo -e "${JAUNE}3.${NC} /var/log/dmesg"
    echo -e "${JAUNE}4.${NC} Autre (spécifiez le chemin)"
    echo -n "Votre choix: "
    read choix_log
    
    case $choix_log in
        1) fichier="/var/log/syslog" ;;
        2) fichier="/var/log/auth.log" ;;
        3) fichier="/var/log/dmesg" ;;
        4) 
            echo -n "Entrez le chemin complet du fichier log: "
            read fichier 
            ;;
        *) echo "Choix invalide"; return ;;
    esac
    
    if [ -f "$fichier" ]; then
        echo -e "${JAUNE}Dernières 20 lignes de $fichier:${NC}"
        separation
        sudo tail -n 20 "$fichier" 2>/dev/null || tail -n 20 "$fichier" 2>/dev/null || echo "Impossible d'accéder au fichier. Essayez avec sudo."
    else
        echo "Le fichier $fichier n'existe pas."
    fi
}

# Fonction pour vider le cache et libérer de la mémoire
vider_cache() {
    separation
    echo -e "${VERT}LIBÉRATION DE MÉMOIRE${NC}"
    separation
    echo -e "${JAUNE}Avant:${NC}"
    free -h | grep "Mem:"
    
    echo -e "\n${JAUNE}Vidage du cache...${NC}"
    # On a besoin des droits sudo pour cette commande
    echo "Entrez votre mot de passe si demandé (la commande sera exécutée avec sudo)"
    sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches" || echo "Impossible d'exécuter la commande. Droits sudo nécessaires."
    
    echo -e "\n${JAUNE}Après:${NC}"
    free -h | grep "Mem:"
}

# Boucle principale du menu
while true; do
    afficher_menu
    read choix
    
    case $choix in
        1) 
            afficher_titre
            info_systeme
            attendre
            ;;
        2) 
            afficher_titre
            espace_disque
            attendre
            ;;
        3) 
            afficher_titre
            utilisateurs_connectes
            attendre
            ;;
        4) 
            afficher_titre
            top_processus
            attendre
            ;;
        5) 
            afficher_titre
            tester_connexion
            attendre
            ;;
        6) 
            afficher_titre
            chercher_fichier
            attendre
            ;;
        7) 
            afficher_titre
            voir_log
            attendre
            ;;
        8) 
            afficher_titre
            vider_cache
            attendre
            ;;
        0) 
            clear
            echo -e "${VERT}Merci d'avoir utilisé ce menu interactif. À bientôt !${NC}"
            exit 0
            ;;
        *) 
            echo -e "${ROUGE}Choix invalide. Veuillez réessayer.${NC}"
            sleep 2
            ;;
    esac
done