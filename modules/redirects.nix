{ config, lib, ... }:

with lib;

let
  redirects = config.webDeploy.redirects;
in
{
  options.webDeploy.redirects = mkOption {
    type = with types; attrsOf str;
    default = {};
    example = literalExpression
      ''
      {
        "www.gosteadily.com" = "gosteadily.com";
      }
      '';
  };

  config.services.nginx = {
    virtualHosts = mapAttrs'
      (from: to: {
        name = from;
        value = {
          globalRedirect = to;
        };
      })
      redirects;
  };
}
