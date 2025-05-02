############################################################################
#
#  Nix commands related to the local machine
#
###########################################################################

default:
    @just --list

# nixos-rebuild switch
deploy: emacs-clean
    nixos-rebuild switch --flake . --use-remote-sudo 

# deploy with show-trace and verbose
debug: emacs-clean
    nixos-rebuild switch --flake . --use-remote-sudo --show-trace --verbose # --option eval-cache false

# test
test: emacs-clean
    nixos-rebuild test --flake . --use-remote-sudo --show-trace --verbose

# update
up:
    nix flake update

# usage: just upp i=home-manager
upp:
    nix flake lock --update-input $(i)

history:
    nix profile history --profile /nix/var/nix/profiles/system

repl:
    nix repl -f flake:nixpkgs

# remove all generations older than 7 days
clean:
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# garbage collect all unused nix store entries
gc:
    sudo nix-collect-garbage --delete-old

###############################################################
#  Quick Test - Emacs
###############################################################

# remove emacs init
emacs-clean:
    rm -rf ${HOME}.config/emacs/init.el

# sync new emacs config
emacs-test: emacs-clean
    rsync -avz --copy-links home/emacs/config/init.el ${HOME}/.config/emacs/init.el
