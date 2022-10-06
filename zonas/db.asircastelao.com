$TTL    3600
@       IN      SOA     ns.asircastelao.com. sdelaiglesialorenzo.danielcastelao.org. (
                   2022021002           ; Serial
                         3600           ; Refresh [1h]
                          600           ; Retry   [10m]
                        86400           ; Expire  [1d]
                          600 )         ; Negative Cache TTL [1h]
;
@       IN      NS      ns.asircastelao.com.
@       IN      MX      10 servidorcorreo.asircastelao.org.

ns     IN      A       10.1.0.254
etch    IN      A       10.1.0.2

pop.asircastelao.com.     IN      CNAME   ns
www.asircastelao.com.      IN      CNAME   etch
mail.asircastelao.com.     IN      CNAME   etch