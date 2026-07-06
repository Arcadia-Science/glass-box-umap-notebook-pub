# From black box to glass box: Making UMAP embeddings interpretable with exact feature contributions

This code repository contains or points to all materials required for creating and hosting the publication entitled, *"From black box to glass box: Making UMAP embeddings interpretable with exact feature contributions"*.

The publication is hosted at [this URL](https://arcadia-science.github.io/glass-box-umap-notebook-pub/).

> [!IMPORTANT]
> Since this publication, we've released [`glass-box-umap`](https://glass-box-umap.readthedocs.io), a Python package that implements the method described here. If you want to apply Glass Box UMAP to your own data, head there.

## Data Description

We apply the glass box UMAP approach to feature interpretation to the human bone marrow gene expression data of [A sandbox for prediction and integration of DNA, RNA, and proteins in single cells by Luecken et al. 2021](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE194122), which is included as the example dataset in ScanPy. 

## Reproduce

Please see [SETUP.qmd](pages/SETUP.qmd).

**NOTE**: you must run the following command to properly clone the submodule with the repo below:
```
git clone https://github.com/Arcadia-Science/glass-box-umap-notebook-pub.git --recurse-submodules
```

If you already have the repo without the submodule from the normal clone command, run this to add the submodule:
```
git submodule update --init --recursive
```

## Contribute

Please see [CONTRIBUTING.qmd](pages/CONTRIBUTING.qmd).
