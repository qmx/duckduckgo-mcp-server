{
  description = "DuckDuckGo MCP Server - Web search for LLMs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          python = pkgs.python313;
        in
        {
          default = python.pkgs.buildPythonApplication {
            pname = "duckduckgo-mcp-server";
            version = "0.1.1";
            pyproject = true;

            src = ./.;

            build-system = [ python.pkgs.hatchling ];

            dependencies = with python.pkgs; [
              beautifulsoup4
              httpx
              mcp
            ];

            pythonImportsCheck = [ "duckduckgo_mcp_server" ];

            meta = {
              description = "MCP Server for searching via DuckDuckGo";
              homepage = "https://github.com/nickclyde/duckduckgo-mcp-server";
              license = pkgs.lib.licenses.mit;
              mainProgram = "duckduckgo-mcp-server";
            };
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.python313
              pkgs.uv
            ];
          };
        });
    };
}
