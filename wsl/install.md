# Required for R

## Resolve errors

Error: `unable to load shared object '[path/to/]R_X11.so' ...`

Solution:
```
sudo apt install libxt6
sudo apt install libxrender1
```

## Fonts

E.g., required for plotting

GNU FreeFont recommended by the [R Installation and Administration manual](https://cran.r-project.org/doc/manuals/r-release/R-admin.html):
```
sudo apt install fonts-freefont-otf
```
