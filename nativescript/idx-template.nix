/*
 Copyright 2024 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
*/

{ pkgs, template ? "js", ts ? false, ... }: {
  channel = "stable-25.05";
  packages = [
    pkgs.nodejs_24
    pkgs.python313
    pkgs.python313Packages.pip
    pkgs.python313Packages.fastapi
    pkgs.python313Packages.uvicorn
  ];

  bootstrap = ''    
    # Prepare output directory
    mkdir "$out"
    mkdir -p "$out/.idx/"

    # Copy dev environment files
    cp -rf ${./dev.nix} "$out/.idx/dev.nix"
    shopt -s dotglob; cp -r ${./dev}/* "$out"

    # Install NativeScript CLI locally (correct package)
    npm install --no-save nativescript

    # Create project using NativeScript CLI
    npx ns create example \
      --${template} \
      ${if ts then "--ts" else ""} \
      --path "$out"

    # Give write permission for Firebase Studio
    chmod -R +w "$out"

    # Optional local dev CLI install
    cd "$out"; npm install -D nativescript

    # Create lockfile without running install scripts
    cd "$out"; npm install --package-lock-only --ignore-scripts
  '';
}
