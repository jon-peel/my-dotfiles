{ config, lib, pkgs, ... }:

{
  options.my.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";
  };

  config = lib.mkIf config.my.tailscale.enable {
    services.tailscale.enable = true;

    # When a Tailscale exit node is active it adds 192.168.122.0/24 to table 52,
    # routing libvirt VM replies through the Tailscale tunnel instead of virbr0.
    # This service adds two ip rules that fix both directions:
    #   priority 99  — replies TO the VM use main table (not table 52)
    #   priority 100 — traffic FROM the VM exits via the physical gateway
    systemd.services.tailscale-libvirt-routing = {
      description = "Fix libvirt VM routing when Tailscale exit node is active";
      after       = [ "network-online.target" "tailscaled.service" "libvirtd.service" ];
      wants       = [ "network-online.target" ];
      wantedBy    = [ "multi-user.target" ];
      path        = [ pkgs.iproute2 ];
      serviceConfig = {
        Type            = "oneshot";
        RemainAfterExit = true;
        ExecStart       = pkgs.writeShellScript "tailscale-libvirt-fix" ''
          GW=$(ip route show table main \
                | grep '^default' | grep -v tailscale \
                | awk '{print $3}' | head -1)
          DEV=$(ip route show table main \
                | grep '^default' | grep -v tailscale \
                | awk '{print $5}' | head -1)

          if [ -z "$GW" ]; then
            echo "No physical gateway found — skipping libvirt routing fix"
            exit 0
          fi

          echo "libvirt routing fix: gateway=$GW dev=$DEV"
          ip route replace table 200 default via "$GW" dev "$DEV"
          ip rule add to  192.168.122.0/24 lookup main priority  99 2>/dev/null || true
          ip rule add iif virbr0           lookup 200  priority 100 2>/dev/null || true
        '';
      };
    };
  };
}
