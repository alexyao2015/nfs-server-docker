nfs-server-docker

# NFS Exports

https://linux.die.net/man/5/exports
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/deployment_guide/s1-nfs-server-config-exports

# Enable v3

It seems that v3 can be used by also starting these services


/usr/sbin/rpc.idmapd
/usr/sbin/rpc.gssd -v
/usr/sbin/rpc.statd