# Makefile for creating an ATLAS LaTeX document

# Copyright (C) 2002-2025 CERN for the benefit of the ATLAS collaboration
#------------------------------------------------------------------------------
# By default compiles $(BASENAME).pdf using Docker.
# Replace mydocument with your main filename or add another target set.
# Replace BIBTEX = biber with BIBTEX = bibtex if you use bibtex instead of biber.
# Adjust FIGSDIR for your figures directory tree.
# Adjust the %.pdf dependencies according to your directory structure.
# Use "make clean" to cleanup.
# Use "make cleanpdf" to delete $(BASENAME).pdf.
# "make cleanall" also deletes the PDF file $(BASENAME).pdf.
# Use "make cleanepstopdf" to remove PDF files created automatically from EPS files.
#   Note that FIGSDIR has to be set properly for this to work.

#-------------------------------------------------------------------------------
# Check which TeX Live installation you have with the command pdflatex --version
PDFLATEX = pdflatex
# BIBTEX   = bibtex
BIBTEX   = biber

#-------------------------------------------------------------------------------
# The main document filename
BASENAME = ANA-TRIG-2021-01-PAPER

#-------------------------------------------------------------------------------
# Docker configuration
DOCKER_IMAGE ?= ana-trig-latex:latest
DOCKER_RUN   = docker run --rm -v "$(CURDIR)":/workdir -w /workdir -e HOME=/tmp --user $(shell id -u):$(shell id -g) $(DOCKER_IMAGE)

#-------------------------------------------------------------------------------
# Adjust this according to your top-level figures directory
# This directory tree is used by the "make cleanepstopdf" command
FIGSDIR  = figures
#-------------------------------------------------------------------------------

rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))
EPSTOPDFFILES = $(call rwildcard, $(FIGSDIR), *eps-converted-to.pdf)

# Default target - compile document via Docker container
default: docker-run

.PHONY: default docker-build docker-run docker-pdflatex docker-clean docker-shell
.PHONY: run_latexmk run_pdflatex
.PHONY: newdocument newdocumenttexmf newnotemetadata newpapermetadata newfiles
.PHONY: draftcover preprintcover newdata
.PHONY: version clean cleanpdf cleanall cleanepstopdf help

#-------------------------------------------------------------------------------
# Docker targets
docker-build:
	docker build -t $(DOCKER_IMAGE) .

docker-run: docker-build
	$(DOCKER_RUN) make run_latexmk

docker-pdflatex: docker-build
	$(DOCKER_RUN) make run_pdflatex

docker-clean: docker-build
	$(DOCKER_RUN) make clean

docker-shell: docker-build
	docker run --rm -it -v "$(CURDIR)":/workdir -w /workdir -e HOME=/tmp --user $(shell id -u):$(shell id -g) $(DOCKER_IMAGE) /bin/bash

#-------------------------------------------------------------------------------
# Native / In-container compilation targets
run_latexmk:
	latexmk -pdf $(BASENAME)

run_pdflatex: $(BASENAME).pdf
	@echo "Made $<"

# Specify the tex and bib file dependencies for running pdflatex
%.pdf:	%.tex *.tex *.bib
	$(PDFLATEX) $<
	$(BIBTEX)  $(basename $<)
	$(PDFLATEX) $<
	$(PDFLATEX) $<
#-------------------------------------------------------------------------------

# Default is to make a new paper
new: newnote

newpaper: TEMPLATE=atlas-paper
newpaper: newdocument newfiles newpapermetadata newauxmat

newpapertexmf: TEMPLATE=atlas-paper
newpapertexmf: newdocumenttexmf newfiles newpapermetadata newauxmat

newnote: TEMPLATE=atlas-note
newnote: newdocument newfiles newnotemetadata

newnotetexmf: TEMPLATE=atlas-note
newnotetexmf: newdocumenttexmf newfiles newnotemetadata

newbook: TEMPLATE=atlas-book
newbook: newdocument newfiles newpapermetadata

newbooktexmf: TEMPLATE=atlas-book
newbooktexmf: newdocumenttexmf newfiles newpapermetadata

draftcover:
	cp template/atlas-draft-cover.tex $(BASENAME)-draft-cover.tex

preprintcover:
	cp template/atlas-preprint-cover.tex $(BASENAME)-preprint-cover.tex

newdata:
	sed s/atlas-document/$(BASENAME)/ template/atlas-hepdata-main.tex >$(BASENAME)-hepdata-main.tex
	cp template/atlas-hepdata.tex $(BASENAME)-hepdata.tex

newdocument:
	sed s/atlas-document/$(BASENAME)/ template/$(TEMPLATE).tex >$(BASENAME).tex

newdocumenttexmf:
	sed s/atlas-document/$(BASENAME)/ template/$(TEMPLATE).tex | \
	sed 's/\\RequirePackage{latex\/atlaslatexpath}/% \\RequirePackage{latex\/atlaslatexpath}/' \
	>$(BASENAME).tex

newpapermetadata:
	cp template/atlas-paper-metadata.tex $(BASENAME)-metadata.tex

newnotemetadata:
	cp template/atlas-note-metadata.tex $(BASENAME)-metadata.tex

newfiles:
	echo "% Put you own bibliography entries in this file" > $(BASENAME).bib
	touch $(BASENAME)-defs.sty

newauxmat:
	cp template/atlas-auxmat.tex $(BASENAME)-auxmat.tex
	cp template/atlas-hepdata.tex $(BASENAME)-hepdata.tex

help:
	@echo "Available commands:"
	@echo "  make                     - Compile paper via Docker (builds image if needed)"
	@echo "  make docker-build        - Build the Docker image"
	@echo "  make docker-run          - Compile paper using latexmk in Docker"
	@echo "  make docker-pdflatex     - Compile paper using pdflatex/biber in Docker"
	@echo "  make docker-shell        - Open interactive shell inside Docker container"
	@echo "  make run_latexmk         - Compile paper directly using local latexmk"
	@echo "  make run_pdflatex        - Compile paper directly using local pdflatex"
	@echo "  make clean               - Clean auxiliary LaTeX files"
	@echo "  make cleanpdf            - Clean output PDF files"
	@echo "  make cleanall            - Clean auxiliary files and PDFs"
	@echo "  make cleanepstopdf       - Remove PDFs converted from EPS"

clean:
	@echo "Cleaning auxiliary LaTeX files..."
	@rm -f *.toc *.aux *.lof *.lot *.log *.out \
		*.bbl *.blg *.brf *.bcf *-blx.bib *.run.xml \
		*.cb *.ind *.idx *.ilg *.inx *.tdo \
		*.synctex.gz *-SAVE-ERROR *~ *.fls *.fdb_latexmk .*.lb spellTmp \
		$(BASENAME)-blx.bib $(BASENAME).bbl
	@find sections tables -type f \( -name "*.aux" -o -name "*.log" -o -name "*~" \) -exec rm -f {} + 2>/dev/null || true
	@echo "Auxiliary files cleaned."

cleanpdf:
	@echo "Cleaning generated PDF files..."
	@rm -f $(BASENAME).pdf $(BASENAME)-draft-cover.pdf $(BASENAME)-preprint-cover.pdf $(BASENAME)-hepdata-main.pdf paper-diff.pdf
	@echo "PDF files cleaned."

cleanall: clean cleanpdf cleanepstopdf

# Clean the PDF files created automatically from EPS files
cleanepstopdf:
	@echo "Removing PDF files made automatically from EPS files..."
	@if [ -n "$(EPSTOPDFFILES)" ]; then rm -f $(EPSTOPDFFILES); fi
