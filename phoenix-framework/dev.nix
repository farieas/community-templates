# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-25.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.inotify-tools
    pkgs.elixir
    pkgs.elixir_ls
    pkgs.watchman
    pkgs.postgresql
  ];
  # Sets environment variables in the workspace
  env = {};

  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
       "elixir-lsp.elixir-ls"
    ];
    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
           command = ["mix" "phx.server" "--" "--port" "$PORT" "--bind" "0.0.0.0"];
          manager = "web";
          env = {
            PORT = "$PORT";
          };
        };
      };
    };
    # Workspace lifecycle hooks
  workspace = {
      # 1. onCreate: Database setup (runs only on first creation)
      onCreate = {
        setup-project = ''
          psql --dbname=postgres -c "CREATE USER \"postgres\" PASSWORD 'postgres' CREATEDB LOGIN;"
          mix local.hex --force
          mix setup
        '';
        default.openFiles = [ "README.md" ];
      };
      
      # 2. onStart: Database startup and delay (runs every time the workspace starts)
      onStart = {
        start-postgres-with-delay = ''
          export PGDATA="$HOME/pgdata"
          
          # Initialize DB data directory if it doesn't exist
          if [ ! -d "$PGDATA" ]; then
            echo "Initializing PostgreSQL data directory..."
            ${pkgs.postgresql}/bin/initdb -D "$PGDATA"
          fi
          
          echo "Starting PostgreSQL server..."
          ${pkgs.postgresql}/bin/pg_ctl -D "$PGDATA" -l "$HOME/postgres.log" start
          
          # CRITICAL: Pause for 5 seconds to ensure the connection is open
          echo "Waiting 5 seconds for PostgreSQL to be ready..."
          sleep 5 
          echo "PostgreSQL service started and ready for connections."
        '';
      };
    };
  };
}
