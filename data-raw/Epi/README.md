Showing how to generate cases and staff numbers
================

The first step (after installing the package) is to load the library
`epicaser`

``` r
library(epicaser)
library(ggplot2)
library(dplyr)
```

Use the function `generate_epi_cases()` to generate synthetic data, so
that we can test the model.

``` r
cases <- generate_epi_cases(staff_per_100K = 1200,
                            staff_recovery_delay = 6,
                            staff_absenteeism = 0.03)
cases
```

    ## # A tibble: 101 × 7
    ##      Day Date        Model Cases AvailableStaff Model_Available_Staff
    ##    <int> <date>      <dbl> <dbl>          <dbl>                 <dbl>
    ##  1     1 2024-03-01  0         0           1122                 1176 
    ##  2     2 2024-03-02  0.624     0           1126                 1147.
    ##  3     3 2024-03-03  1.01      1           1149                 1124.
    ##  4     4 2024-03-04  1.65      4           1161                 1104.
    ##  5     5 2024-03-05  2.67      0           1076                 1089.
    ##  6     6 2024-03-06  4.34      5           1098                 1076.
    ##  7     7 2024-03-07  7.05      1           1065                 1065.
    ##  8     8 2024-03-08 11.4      14           1101                 1056.
    ##  9     9 2024-03-09 18.6      19           1090                 1049.
    ## 10    10 2024-03-10 30.1      34           1034                 1042.
    ## # ℹ 91 more rows
    ## # ℹ 1 more variable: Model_Unavailable_Staff <dbl>

Plot the cases

![](README_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

Plot the staff numbers. These are Poisson random variables with the mean
taken from the ODE model.

    ## Warning: Use of `cases$AvailableStaff` is discouraged.
    ## ℹ Use `AvailableStaff` instead.
    ## Use of `cases$AvailableStaff` is discouraged.
    ## ℹ Use `AvailableStaff` instead.

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->
