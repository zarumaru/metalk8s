Integrating with MetalK8s
=========================

With a focus on having minimal human actions required, both in its deployment
and operation, MetalK8s also intends to ease deployment and operation of
complex applications, named *Solutions*, on its cluster.

This document defines what a *Solution* refers to, the responsibilities of each
party in this integration, and will link to relevant documentation pages for
detailed information.

What is a *Solution*?
---------------------

We use the term *Solution* to describe a packaged Kubernetes application,
archived as an ISO disk image, containing:

- A set of OCI images to inject in MetalK8s image registry
- An `Operator`_, to deploy on the cluster
- Optionally, a UI for managing and monitoring the application, represented by
  a standard Kubernetes ``Deployment``

For more details, see the following documentation pages:

- `Solution archive guidelines`_
- `Solution Operator guidelines`_
- (TODO) Solution UI guidelines

Once a Solution is deployed on MetalK8s, a user can start creating the
appropriate ``CustomResource(s)`` defined by the Solution Operator, using
either the Solution UI or the Kubernetes API, to effectively deploy one or more
instances of the application packaged in the Solution.

How is a *Solution* declared in MetalK8s?
-----------------------------------------

MetalK8s already uses a ``BootstrapConfiguration`` object, stored in
``/etc/metalk8s/bootstrap.yaml``, to define how the cluster should be
configured from the bootstrap node, and what versions of MetalK8s are available
to the cluster.

In the same vein, we want to use a ``SolutionsConfiguration`` object, stored in
``/etc/metalk8s/solutions.yaml``, to declare which Solutions are available to
the cluster, from the bootstrap node.

Here is how it could look::

    apiVersion: metalk8s.scality.com/v1alpha1
    kind: SolutionsConfiguration
    solutions:
      - name: my-storage
        archives:
          - /solutions/storage_1.0.0.iso
          - /solutions/storage_latest.iso
      - name: my-computing
        archives:
          - /other_solutions/computing.iso

There would be no explicit version information about what the archives
contain. Instead, we want the archive itself to contain such information (more
details in the `Solution archive guidelines`_), and to discover it ourselves.

A ``SolutionsConfiguration`` as defined above would be sufficient for deploying
both ``my-storage`` and ``my-computing`` Solutions ; we would simply choose to
deploy the latest, in SemVer terms, available version among the declared
``archives``.
In order to declare which version to actually deploy, one can use the
``activeVersion`` field, as so::

    [...]
    solutions:
      - name: my-storage
        archives:
          - ...
        activeVersion: 1.0.1

If the ``activeVersion`` declared is not available among the declared
``archives``, attempting to deploy the Solution will fail.

Responsibilities of each party
------------------------------

This section intends to define the boundaries between MetalK8s and the
Solutions to integrate with, in terms of "who is doing what?".

.. Not working on GH: "note:: This is still a work in progress."

**NOTE:** This is still a work in progress.


.. Not working on GH: topic:: MetalK8s

**MetalK8s**::

    MUST:
    - Handle reading and mounting of the Solution ISO archive
    - Provide tooling to deploy a Solution's Operator and UI
    - Provide tooling to upgrade a Solution's Operator and UI

    MAY:
    - Provide tooling to verify signatures in a Solution ISO
    - Expose management of Solutions in its own UI

.. Not working on GH: topic:: Solution

**Solution**::

    MUST:
    - Comply with the standard archive structure defined by MetalK8s
    - Comply with the `CustomResource`s standards defined by MetalK8s
    - Set up its own monitoring

    MAY:
    - Use MetalK8s monitoring services (Prometheus and Grafana)

Interaction diagrams
--------------------

We include detailed interaction sequence diagrams for describing how MetalK8s
will handle user input when deploying / upgrading Solutions.

Their UML definitions will be included in the repository, while generating the
images is left to the user (just run ``make`` from the ``docs/`` directory).

Solution deployment
^^^^^^^^^^^^^^^^^^^

See `the Solutions deployment diagram definition`_.

.. NOTE: would be interesting to embed the generated images here...

Solution upgrade
^^^^^^^^^^^^^^^^

TODO


.. References

.. _the terms introduced by CoreOS: https://coreos.com/blog/introducing-operators.html
.. _the Solutions deployment diagram definition: ./deployment.uml
.. _Solution archive guidelines: ./archive.rst
.. _Solution Operator guidelines: ./operator.rst
