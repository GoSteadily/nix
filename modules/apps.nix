{ config, lib, ... }:

with lib;

let
  appOptions =
    {
      options = {
        description = mkOption {
          type = types.str;
          example = literalExpression "Run my app server.";
        };

        domain = mkOption {
          type = types.str;
          example = literalExpression "app.gosteadily.com";
        };

        aliases = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [ "alias0.gosteadily.com" "alias1.gosteadily.com" ];
        };

        port = mkOption {
          type = types.port;
          example = literalExpression "3000";
        };

        command = mkOption {
          type = types.str;
          example = literalExpression "/path/to/binary --arg1 --arg2=foo";
        };

        environment = mkOption {
          type = with types; attrsOf str;
          default = { };
          example = literalExpression
            ''
              {
                NAME = "VALUE";
              }
            '';
        };

        maxRuntime = mkOption {
          type = types.str;
          default = "infinity";
        };
      };
    };
in
{
  options.webDeploy.apps = mkOption {
    type = with types; attrsOf (submodule appOptions);
    default = { };
    example = literalExpression
      ''
        {
          "my-app-server" = {
            description = "Run my app server.";
            domain = "app.gosteadily.com";
            port = 3000;
            command = "/path/to/binary --arg1 --arg2=foo";
          };
        }
      '';
  };

  config =
    let
      apps = config.webDeploy.apps;
      username = config.webDeploy.user.name;
    in
    mkIf (apps != { })
      {
        systemd.services = mapAttrs'
          (name: app:
            {
              name = name;
              value = {
                wantedBy = [ "multi-user.target" ];
                after = [ "network.target" ];
                description = app.description;
                environment = app.environment;
                serviceConfig = {
                  Type = "simple";
                  User = username;
                  Restart = "always";
                  RuntimeMaxSec = app.maxRuntime;
                  WorkingDirectory = "~";
                  ExecStart = app.command;
                };
              };
            }
          )
          apps;

        services.nginx.enable = true;

        services.nginx.virtualHosts = mapAttrs'
          (_: app:
            {
              name = app.domain;
              value = {
                forceSSL = true;
                enableACME = true;
                serverAliases = app.aliases;
                locations = {
                  "/" = {
                    proxyPass = "http://127.0.0.1:${builtins.toString app.port}";
                  };
                };
              };
            }
          )
          apps;
      };
}
