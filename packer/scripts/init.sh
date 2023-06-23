#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
# echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

echo "============================ Installing update ==========================="
apt update -y
apt upgrade -y

apt-get update -y
apt-get upgrade -y

apt-get update -y --fix-missing


echo "============================ Installing Desktop ==========================="
# apt update -y
# apt upgrade -y

# apt install -y tasksel

# apt-get update -y
dpkg --configure -a

# apt-get update -y

echo "============================ tasksel ==========================="

# apt install -y ubuntu-desktop-niminal
# tasksel install ubuntu-desktop-niminal

systemctl set-default graphical.target

echo "============================ Validating Installed Desktop Service ==========================="

systemctl status graphical.target

systemctl restart graphical.target

systemctl status graphical.target

echo "============================ tasksel ==========================="

# apt install -y ubuntu-desktop-niminal
# tasksel install ubuntu-desktop-niminal


###
apt-get remove -y thunderbird* transmission* gnome-todo* baobab rhythmbox cheese vino shotwell totem usb-creator-gtk deja-dup gnome-calendar remmina simple-scan  aisleriot gnome-mahjongg gnome-mines gnome-sudoku branding-ubuntu libreoffice-style-breeze libreoffice-gnome libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-math libreoffice-ogltrans libreoffice-pdfimport example-content ubuntu-web-launchers libreoffice-l10n-en-gb libreoffice-l10n-es libreoffice-l10n-zh-cn libreoffice-l10n-zh-tw libreoffice-l10n-pt libreoffice-l10n-pt-br libreoffice-l10n-de libreoffice-l10n-fr libreoffice-l10n-it libreoffice-l10n-ru libreoffice-l10n-en-za libreoffice-help-en-gb libreoffice-help-es libreoffice-help-zh-cn libreoffice-help-zh-tw libreoffice-help-pt libreoffice-help-pt-br libreoffice-help-de libreoffice-help-fr libreoffice-help-it libreoffice-help-ru libreoffice-help-en-us gir1.2-rb-3.0 gir1.2-totem-1.0 gir1.2-totemplparser-1.0 guile-2.0-libs libabw-0.1-1 libavahi-ui-gtk3-0 libdmapsharing-3.0-2 libexttextcat-2.0-0 libexttextcat-data libfreehand-0.1-1 libgnome-games-support-1-3 libgnome-games-support-common libgom-1.0-0 libgrilo-0.3-0 liblangtag-common liblangtag1 libmessaging-menu0 libmhash2 libminiupnpc10 libmwaw-0.3-3 libmythes-1.2-0 libnatpmp1 libneon27-gnutls liborcus-0.13-0 libpagemaker-0.0-0 librdf0 libreoffice-avmedia-backend-gstreamer libreoffice-base-core libreoffice-common libreoffice-core libreoffice-draw libreoffice-gtk3 libreoffice-style-elementary libreoffice-style-galaxy libreoffice-style-tango libraptor2-0 librasqal3 librevenge-0.0-0 librhythmbox-core10 libtotem0 libvisio-0.1-1 libwpd-0.10-10 libwpg-0.3-3 libwps-0.4-4 libyajl2 python3-uno rhythmbox-data rhythmbox-plugin-alternative-toolbar rhythmbox-plugins remmina-common remmina-plugin-rdp remmina-plugin-secret remmina-plugin-vnc duplicity seahorse-daemon shotwell-common totem-common totem-plugins  cheese-common libgnome-todo gnome-video-effects libcheese-gtk25 libcheese8 uno-libs3 ure zeitgeist-core hunspell-de-at-frami hunspell-de-ch-frami hunspell-de-de-frami hunspell-en-au hunspell-en-ca hunspell-en-gb hunspell-en-za hunspell-es hunspell-fr hunspell-fr-classical hunspell-it hunspell-pt-br hunspell-pt-pt hunspell-ru hyphen-de hyphen-en-ca hyphen-en-gb hyphen-en-us hyphen-fr hyphen-hr hyphen-it hyphen-pl hyphen-pt-br hyphen-pt-pt hyphen-ru mythes-de mythes-de-ch mythes-en-au mythes-en-us mythes-fr mythes-it mythes-pt-pt mythes-ru
apt update -y
apt install --assume-yes perl gcc make git
