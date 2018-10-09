FIGS := $(shell ls fig/fig-*.pdf)
ALL_PDF_FIG := $(shell find . -name fig-\*.pdf)
ALL_EPS_FIG := $(join $(dir $(ALL_PDF_FIG)),  $(notdir $(ALL_PDF_FIG:.pdf=.eps)))
LAST_SUBMISSION := 6a1b120db
	

all: geissmann_et_al_2018.pdf manuscript-changes.pdf

geissmann_et_al_2018.pdf: geissmann_et_al_2018.tex manuscript.pdf all-figures.pdf manuscript.tex functionalities_table.pdf
	pdflatex $<

functionalities_table.pdf: functionalities_table.tex
	pdflatex $<
	
all-figures.pdf: $(FIGS)
	pdftk $^ cat output $@


manuscript.bib: rethomics_manuscript.bib
	cat $< | sed 's/journaltitle =/journal =/g' > $@
	#cat $< | sed 's/journal =/journal =/g' > $@

manuscript.tex: manuscript.Rnw results.Rnw manuscript.bib
	R -e "library(knitr);knit(\"$<\")"

manuscript.pdf: manuscript.tex all-figures.pdf
	pdflatex $<
	bibtex manuscript.aux
	pdflatex $<
	pdflatex $<

manuscript-changes.pdf: manuscript.tex all-figures.pdf
	latexdiff-vc -r $(LAST_SUBMISSION) $<  --pdf  --force 
	mv manuscript-diff$(LAST_SUBMISSION).pdf $@ 
	rm manuscript-diff$(LAST_SUBMISSION).tex 

eps_figs: $(ALL_EPS_FIG)
	
%.eps: %.pdf
	@echo converting $<  to $@
	pdf2ps $< -  | ps2eps - > $@
	
clean:
	rm *.log *.aux {manuscript,results}.tex *.out  *.pdf *.blg *.bbl *.tdo  -f 
	rm -rf cache/
	rm -f fig/*.eps fig/*-tmp.svg 
	rm manuscript.bib -f
