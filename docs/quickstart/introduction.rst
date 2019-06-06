Introduction
============

Deploying a MetalK8s cluster, while simple, will be facilitated by
an introductory explanation of a few concepts and an outline of the deployment
procedure that will ensue.

This guide will cover many aspects while not diving too much into the details.
Links to relevant sections of the complete documentation are included when
useful, and a :doc:`/glossary` is provided.

Concepts
^^^^^^^^
Although being familiar with
`Kubernetes concepts <https://kubernetes.io/docs/concepts/>`_
is recommended, the necessary concepts to grasp before installing a MetalK8s
cluster are presented here.

Control-plane and workload-plane
""""""""""""""""""""""""""""""""

.. _`API Server`:
      https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/
.. _Scheduler:
      https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/
.. _`Controller Manager`:
      https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/
.. _etcd: https://etcd.io/


This dichotomy is central to MetalK8s, and often referred to in other
Kubernetes concepts.

The **control-plane** is the set of machines (called :term:`nodes <Node>`) and
the services running there that make up the essential Kubernetes functionality
for running containerized applications, managing declarative objects, and
providing authentication/authorization to end-users as well as services.
The main components making up a Kubernetes control-plane are:

- `API Server`_
- Scheduler_
- `Controller Manager`_

The **workload-plane** indicates the ensemble of nodes where applications
will be deployed via Kubernetes objects, using services provided by the
**control-plane**.

Note that nodes can belong to both planes, so that one can run applications
alongside the control-plane services.

Control-plane nodes often are responsible for providing storage for
`API Server`_, by running `etcd`_. This responsibility may be offloaded to
other nodes from the workload-plane.

Node roles
""""""""""

Determining a :term:`Node` responsibilities is achieved using **roles**.
Roles are stored in :term:`Node manifests <Node manifest>` using labels, of the
form ``node-role.kubernetes.io/<role-name>: ''``.

MetalK8s uses five different **roles**, that may be combined freely:

``node-role.kubernetes.io/master``
  The ``master`` role defines control-plane membership. Control-plane services
  (see above) can only be scheduled on ``master`` nodes.

``node-role.kubernetes.io/etcd``
  The ``etcd`` role marks a node running `etcd`_ for storage of API Server.

``node-role.kubernetes.io/node``
  This role defines a workload-plane node. It is included implicitly by all
  other roles.

``node-role.kubernetes.io/infra``
  The ``infra`` role is specific to MetalK8s. It serves for marking nodes where
  non-critical services provided by the cluster (monitoring stack, UIs, etc.)
  are running.

``node-role.kubernetes.io/bootstrap``
  This marks the :term:`Bootstrap node`. This node is unique in the cluster,
  and runs a few specific services:

  - A package repository for Nodes to install from
  - An OCI registry for :term:`Pods <Pod>` images
  - A Salt Master, deployed with SaltAPI

  In practice, it will be used in conjunction with the ``master`` and ``etcd``
  roles.

.. _quickstart-intro-networks:

Networks
""""""""

.. todo::

   - need physical networks for control-plane and workload-plane (may be the
     same)
   - define how each node in the cluster needs an IP for each network
   - mention virtual networks for Pods and Services, managed by the CNI


Installation plan
^^^^^^^^^^^^^^^^^

In this guide, the depicted installation procedure is for a medium sized
cluster, using three control-plane nodes and two worker nodes. Hints for
deploying a smaller architecture will be included, though sparse. Refer to
the :doc:`/installation-guide/index` for extensive explanations of possible
cluster architectures.

Here is how it will happen:

#. :doc:`Setup <./setup>` of the environment (with requirements and example
   OpenStack deployment)
#. :doc:`Deployment <./bootstrap>` of the :term:`Bootstrap node`
#. :doc:`Expansion <./expansion>` of the cluster from the Bootstrap node

.. todo:: Include a link to example Solution deployment?
