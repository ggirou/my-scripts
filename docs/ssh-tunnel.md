Use SSH tunnel as a SOCKS proxy
-------------------------------

-------------------------------------

# Open SSH tunnel

## Linux

    ssh -fNCD 8080 user@hostname -p 443

Note:

- `fN`: requests ssh to go to background and do not execute a remote command.
- `C`: requests compression of all data.
- `D 8080`: opens "dynamic" proxy port.
- `user@hostname -p 443`: connects on `hostname` on port `443` and log as `user`

## Putty

-------------------------------------

# Configure browser proxy

## Permanent configuration

## FoxyProxy extension
