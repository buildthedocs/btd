- TODO: themes/templates
- TODO: how to use your own docker images/registry
- TODO: how to customize the builder/build process

---

- [Control Flow (build process)](#control-flow-build-process)

# Control Flow (build process)

- parse configuration file
  - generate versions list and check status
- for each version
  - build html
  - (conditionally) build latex
  - move artifacts to output subdir
- (optional) add landing page
- push products to hosting service
