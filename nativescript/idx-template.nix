/*
 Copyright 2024 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
*/
{ pkgs, template ? "js", ts ? false, ... }: {
  channel = "stable-25.05";
  packages = [
    pkgs.nodejs
  ];
  bootstrap = ''    
    mkdir "$out"
    mkdir -p "$out/.idx/"
    cp -rf ${./dev.nix} "$out/.idx/dev.nix"
    shopt -s dotglob; cp -r ${./dev}/* "$out"
    npm install nativescript
    ./node_modules/nativescript/bin/ns create example --${template} ${if ts then "--ts" else ""} --path "$out"
    chmod -R +w "$out"
    cd "$out"; npm install -D nativescript
    cd "$out"; npm install --package-lock-only --ignore-scripts
  '';
}