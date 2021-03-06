
# gfplot: An R package for data extraction and plotting of British Columbia groundfish data

<!-- badges: start -->

[![R-CMD-check](https://github.com/pbs-assess/gfplot/workflows/R-CMD-check/badge.svg)](https://github.com/pbs-assess/gfplot/actions)
<!-- badges: end -->

Facilitates the creation of an annual groundfish data synopsis report
with [gfsynopsis](https://github.com/pbs-assess/gfsynopsis).

Note that the documentation is incomplete in some places. Please post in
the [issue tracker](https://github.com/pbs-assess/gfplot/issues) if you
have questions or suggestions on how the package or its documentation
could be improved. We welcome pull requests!

In addition to the help available through the R console, a [web version
of the documentation is
available](https://pbs-assess.github.io/gfplot/index.html).

# Installation

First, install INLA:

``` r
install.packages("INLA", repos = c(getOption("repos"), 
  INLA = "https://inla.r-inla-download.org/R/stable"), dep = TRUE)
```

The gfplot package can then be installed and loaded with:

``` r
# install.packages("devtools")
devtools::install_github("pbs-assess/gfplot")
```

``` r
library(gfplot)
```

Functions specific to PBS:

``` r
fns <- ls("package:gfplot")
sort(fns[grepl("get", fns)])
#>  [1] "get_age_methods"          "get_age_precision"       
#>  [3] "get_catch"                "get_commercial_samples"  
#>  [5] "get_cpue_historical"      "get_cpue_index"          
#>  [7] "get_cpue_spatial"         "get_cpue_spatial_ll"     
#>  [9] "get_fishery_ids"          "get_gear_types"          
#> [11] "get_hake_catch"           "get_major_areas"         
#> [13] "get_management"           "get_management_areas"    
#> [15] "get_other_surveys"        "get_sara_dat"            
#> [17] "get_sensor_attributes"    "get_sensor_data_fe_trawl"
#> [19] "get_sensor_data_ll_td"    "get_sensor_data_trawl"   
#> [21] "get_species"              "get_species_groups"      
#> [23] "get_ssids"                "get_survey_index"        
#> [25] "get_survey_samples"       "get_survey_sets"
```

Generic functions for any similarly formatted data:

``` r
sort(fns[grepl("tidy", fns)])
#>  [1] "tidy_age_precision"    "tidy_ages_raw"         "tidy_ages_weighted"   
#>  [4] "tidy_catch"            "tidy_comps"            "tidy_comps_commercial"
#>  [7] "tidy_comps_survey"     "tidy_cpue_historical"  "tidy_cpue_index"      
#> [10] "tidy_lengths_raw"      "tidy_lengths_weighted" "tidy_maturity_months" 
#> [13] "tidy_sample_avail"     "tidy_survey_index"     "tidy_survey_sets"
```

``` r
sort(fns[grepl("fit", fns)])
#> [1] "fit_cpue_index_glmmtmb" "fit_length_weight"      "fit_mat_ogive"         
#> [4] "fit_survey_sets"        "fit_vb"
```

``` r
sort(fns[grepl("plot", fns)])
#>  [1] "plot_age_precision"     "plot_ages"              "plot_catch"            
#>  [4] "plot_catch_spatial"     "plot_cpue_spatial"      "plot_growth"           
#>  [7] "plot_length_weight"     "plot_lengths"           "plot_mat_annual_ogives"
#> [10] "plot_mat_ogive"         "plot_maturity_months"   "plot_predictor_bubbles"
#> [13] "plot_qres_histogram"    "plot_qres_qq"           "plot_sample_avail"     
#> [16] "plot_survey_index"      "plot_survey_sets"       "plot_vb"
```
