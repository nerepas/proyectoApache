$TTL    3600
@       IN      SOA     ns.fabulas.com. nerea.fabulas.org. (
                   2007010401           ; Serial
                         3600           ; Refresh [1h]
                          600           ; Retry   [10m]
                        86400           ; Expire  [1d]
                          600 )         ; Negative Cache TTL [1h]
;
@       IN      NS      ns.fabulas.com.
@       IN      MX      10 servidorcorreo.fabulas.org.

ns     IN      A       10.1.0.254
oscuras    IN      A       10.1.0.253
maravillosas     IN      CNAME   oscuras