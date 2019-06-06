Glossary
========

.. _kubectl: https://kubernetes.io/docs/reference/kubectl/kubectl/
.. |kubectl| replace:: ``kubectl``

.. |see K8s docs| replace:: See also the official Kubernetes documentation for

.. glossary::

   Node
     A Node is a Kubernetes worker machine - either virtual or physical.
     A Node contains the services required to run :term:`Pods <Pod>`.
     See also the official Kubernetes documentation for
     `Nodes <https://kubernetes.io/docs/concepts/architecture/nodes/>`_.

   Node manifest
     The YAML file describing a :term:`Node`.

     |see K8s docs|
     `Nodes management <https://kubernetes.io/docs/concepts/architecture/nodes/#management>`_.

   Bootstrap
   Bootstrap node
     The Bootstrap node is the first machine on which MetalK8s is installed,
     and from where the cluster will be deployed to other machines. It also
     serves as the entrypoint for upgrades of the cluster.

   Pod
     A Pod is a group of one or more containers sharing storage and network
     resources, with a specification of how to run these containers.

     |see K8s docs|
     `Pods <https://kubernetes.io/docs/concepts/workloads/pods/pod/>`_.

   ``kubectl``
     |kubectl| is a CLI interface for interacting with a Kubernetes cluster.

     |see K8s docs| |kubectl|_.


