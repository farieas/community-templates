/*
 Copyright 2024 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
/*
 Copyright 2024 Google LLC

 Licensed under the Apache License, Version 2.0 (the "License");
 Licensed under the Apache License, Version 2.0.
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

    # Copy dev.nix and dev template folder
    cp -rf ${./dev.nix} "$out/.idx/dev.nix"
    shopt -s dotglob; cp -r ${./dev}/* "$out"

    # Install NativeScript CLI locally (required so npx can run without internet)
    npm install --no-save @nativescript/cli

    # Create NativeScript project (Vue/JS/TS depending on template flags)
    npx @nativescript/cli create example \
      --${template} \
      ${if ts then "--ts" else ""} \
      --path "$out"

    # Ensure workspace is writable
    chmod -R +w "$out"

    # Add local dev CLI (optional but helps with IDE intellisense)
    cd "$out"; npm install -D @nativescript/cli

    # Create package-lock only (no install scripts)
    cd "$out"; npm install --package-lock-only --ignore-scripts
  '';
}
