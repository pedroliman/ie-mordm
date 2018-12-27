library(simmer)

set.seed(42)

env <- simmer("SuperDuperSim")
env

patient <- trajectory("patients' path") %>%
  ## add an intake activity 
  seize("nurse", 1) %>%
  timeout(function() rnorm(1, 15)) %>%
  release("nurse", 1) %>%
  ## add a consultation activity
  seize("doctor", 1) %>%
  timeout(function() rnorm(1, 20)) %>%
  release("doctor", 1) %>%
  ## add a planning activity
  seize("administration", 1) %>%
  timeout(function() rnorm(1, 5)) %>%
  release("administration", 1)

env %>%
  add_resource("nurse", 1) %>%
  add_resource("doctor", 2) %>%
  add_resource("administration", 1) %>%
  add_generator("patient", patient, function() rnorm(1, 10, 2))

env %>% 
  run(80) %>% 
  now()

env %>% peek(3)

env %>%
  stepn() %>% # 1 step
  print() %>%
  stepn(3)    # 3 steps

env %>% peek(Inf, verbose=TRUE)

env %>% 
  run(120) %>%
  now()

env %>% 
  reset() %>% 
  run(80) %>%
  now()

## Replicating Many Times:
envs <- lapply(1:100, function(i) {
  simmer("SuperDuperSim") %>%
    add_resource("nurse", 1) %>%
    add_resource("doctor", 2) %>%
    add_resource("administration", 1) %>%
    add_generator("patient", patient, function() rnorm(1, 10, 2)) %>%
    run(80)
})

## Replicating in Parallel
library(parallel)

envs <- mclapply(1:100, function(i) {
  simmer("SuperDuperSim") %>%
    # Adiciona os recursos
    add_resource("nurse", 1) %>%
    add_resource("doctor", 2) %>%
    add_resource("administration", 1) %>%
    # Adicionar a origem de entidades. patient é a trajetória.
    add_generator("patient", patient, function() rnorm(1, 10, 2)) %>%
    # Roda a Simulação por 80 unidades de tempo:
    run(80) %>%
    # Finaliza a simulação pois está em paralelo.
    wrap()
})

# Visualizando resultados de replicações individuais:
envs[[1]] %>% get_n_generated("patient")
#> [1] 8
envs[[1]] %>% get_queue_count("doctor")
#> [1] 0
envs[[1]] %>% get_queue_size("doctor")
#> [1] Inf
envs %>% 
  get_mon_resources() %>%
  head()

envs %>% 
  get_mon_arrivals() %>%
  head()


## Visualização - Simmer Plots:

library(simmer)
library(parallel)

patient <- trajectory("patients' path") %>%
  ## add an intake activity 
  seize("nurse", 1) %>%
  timeout(function() rnorm(1, 15)) %>%
  release("nurse", 1) %>%
  ## add a consultation activity
  seize("doctor", 1) %>%
  timeout(function() rnorm(1, 20)) %>%
  release("doctor", 1) %>%
  ## add a planning activity
  seize("administration", 1) %>%
  timeout(function() rnorm(1, 5)) %>%
  release("administration", 1)

envs <- mclapply(1:100, function(i) {
  simmer("SuperDuperSim") %>%
    add_resource("nurse", 1) %>%
    add_resource("doctor", 2) %>%
    add_resource("administration", 1) %>%
    add_generator("patient", patient, function() rnorm(1, 10, 2)) %>%
    run(80) %>%
    wrap()
})

# Criando Estatísticas de Saída:
envs %>%
  get_mon_arrivals %>%
  dplyr::mutate(waiting_time = end_time - start_time - activity_time)

envs %>%
  get_queue_count()

library(simmer.plot)
# install.packages("simmer.plot")
resources <- get_mon_resources(envs)
plot(resources, metric = "utilization")

plot(resources, metric = "usage", c("nurse", "doctor"), items = "server")

plot(get_mon_resources(envs[[6]]), metric = "usage", "doctor", items = "server", steps = TRUE)

arrivals <- get_mon_arrivals(envs)
plot(arrivals, metric = "flow_time")


## Bank Example:
library(simmer)
library(parallel)

customer <-
  trajectory("Customer's path") %>%
  seize("counter") %>%
  timeout(function() {rexp(1, 1/12)}) %>%
  release("counter")


mclapply(c(393943, 100005, 777999555, 319999772), function(the_seed) {
  set.seed(the_seed)
  
  bank <-
    simmer("bank") %>%
    add_resource("counter", 2) %>%
    add_generator("Customer", customer, function() {c(0, rexp(49, 1/10), -1)})
  
  bank %>% run(until = 400)
  result <-
    bank %>%
    get_mon_arrivals %>%
    dplyr::mutate(waiting_time = end_time - start_time - activity_time)
  
  
  
  paste("Average wait for ", sum(result$finished), " completions was ",
        mean(result$waiting_time), "minutes.")
}) %>% unlist()

