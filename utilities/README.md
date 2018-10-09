# Generate kubectl config

To access the server from your machine, you will need to generate
credentials on the controller and them configure a config file
accordingly.

I created a script to generate this config for you.

First export the controller IP and SSH key you can use:

    export CONTROLLER_IP='x.x.x.x'
    export SSH_KEY='servers.pem'

Then you generate the config:

    ssh ubuntu@$CONTROLLER_IP \
        -i ~/.ssh/$SSH_KEY 'bash -s' < generate_config.sh > kube.conf

Now you should have in this directory a config file names kube.conf.
Use it with kubernetes this way:

    $ export KUBECONFIG=kube.conf
    $ kubectl get nodes
    NAME                                             STATUS   ROLES    AGE     VERSION
    ip-x-x-x-x.eu-west-1.compute.internal   Ready    master   5m45s   v1.12.1
    ip-x-x-x-x.eu-west-1.compute.internal   Ready    <none>   5m32s   v1.12.1
