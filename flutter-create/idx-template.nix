{pkgs, sample ? "none", template ? "app", blank ? false, platforms ? "web,android", ...}: {
channel = "stable-25.05"; # or "unstable"
    packages = [
        pkgs.flutterPackages-source.stable
    ];
    bootstrap = ''
        flutter create "$out" --template="${template}" --platforms="${platforms}" ${if sample == "none" then "" else "--sample=${sample}"} ${if blank then "-e" else ""}
        mkdir "$out"/.idx
        cp ${./dev.nix} "$out"/.idx/dev.nix
        install --mode u+rw ${./dev.nix} "$out"/.idx/dev.nix
        chmod -R u+w "$out"
    '';
}
