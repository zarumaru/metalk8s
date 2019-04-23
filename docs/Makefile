# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SPHINXPROJ    = MetalK8s
SOURCEDIR     = .
BUILDDIR      = _build
SPHINXAUTOBUILD = sphinx-autobuild
SPHINXAUTOBUILDOPTS = \
	--watch "$(SOURCEDIR)/.." \
	--ignore '*~' \
	--ignore '*.swp' \
	--ignore '*.swx' \
	--re-ignore '4913$$' \
	--re-ignore '\.git/'

default: help
.PHONY: default

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

# PlantUML diagrams
DIAGRAM_SOURCES := $(wildcard **/*.uml)

diagrams: diagrams-png diagrams-svg
.PHONY: diagrams

diagrams-png: $(patsubst %.uml,%.png,$(SOURCES))
.PHONY: diagrams-png

diagrams-svg: $(patsubst %.uml,%.svg,$(SOURCES))
.PHONY: diagrams-svg

%.png: %.uml
	@echo Rendering $< into $@
	@plantuml -p -tpng > $@ < $<

%.svg: %.uml
	@echo Rendering $< into $@
	@plantuml -p -tsvg > $@ < $<

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

