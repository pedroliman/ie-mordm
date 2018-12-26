library(queuecomputer)
library(ggplot2)
library(dplyr)

set.seed(1)

n <- 100

arrivals_1 <- c(100 + cumsum(rexp(n)), 500 + cumsum(rexp(n)))
service_1 <- rexp(2*n, 1/2.5)

queue_1 <- queue_step(arrivals = arrivals_1, service = service_1, servers = 2)

walktimes <- rexp(2*n, 1/100)

arrivals_2 <- lag_step(arrivals = queue_1, service = walktimes)
service_2 <- rexp(2*n, 1/3)

queue_2 <- queue_step(arrivals = arrivals_2, service = service_2, servers = 1)

head(arrivals_1)
#> [1] 100.7552 101.9368 102.0825 102.2223 102.6584 105.5534
head(queue_1$departures_df)
#> # A tibble: 6 x 6
#>   arrivals service departures   waiting system_time server
#>      <dbl>   <dbl>      <dbl>     <dbl>       <dbl>  <int>
#> 1     101.   0.189       101. -6.38e-15       0.189      1
#> 2     102.   2.57        105.  4.44e-15       2.57       2
#> 3     102.   1.69        104.  0.             1.69       1
#> 4     102.   2.00        106.  1.55e+ 0       3.55       1
#> 5     103.   0.435       105.  1.84e+ 0       2.28       2
#> 6     106.   1.68        107.  0.             1.68       2
head(arrivals_2)
#> [1] 120.3923 105.6711 227.5242 175.9008 339.9853 108.7119
head(queue_2$departures_df)
#> # A tibble: 6 x 6
#>   arrivals service departures   waiting system_time server
#>      <dbl>   <dbl>      <dbl>     <dbl>       <dbl>  <int>
#> 1     120.   5.16        126. -2.66e-15        5.16      1
#> 2     106.   1.58        107.  0.              1.58      1
#> 3     228.   0.114       291.  6.32e+ 1       63.3       1
#> 4     176.   2.35        186.  8.02e+ 0       10.4       1
#> 5     340.   3.20        404.  6.13e+ 1       64.5       1
#> 6     109.   1.23        110.  0.              1.23      1

summary(queue_1)
#> Total customers:
#>  200
#> Missed customers:
#>  0
#> Mean waiting time:
#>  11.4
#> Mean response time:
#>  13.7
#> Utilization factor:
#>  0.38410206651912
#> Mean queue length:
#>  3.7
#> Mean number of customers in system:
#>  4.46

summary(queue_2)