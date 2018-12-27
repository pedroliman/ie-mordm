library(simmer)
library(dplyr)
library(parallel)

modelo_capacitores = function(v_capacidades, v_custos = c(20, 15, 7, 25) * 1000, v_tempos_ciclo = c(20, 5, 6, 15), reps = 3, tempo_sim = 500) {

  # # Se não tem vetor de custos usar o padrão:
  # if(missing(v_custos)){
  #   v_custos = c(20, 15, 7, 25) * 1000
  # }
  
  # if(missing(v_capacidades)){
  #   v_capacidades = c(1,1,1,1)
  # }
  
  
  # # E se não tem tempos de ciclo, usar o padrão:
  # if(missing(v_tempos_ciclo)){
  #   v_tempos_ciclo = c(20, 5, 6, 15)
  # }
  
 # Custo Total:
  
  #Garantindo que as Capaciddes são inteiras
  v_capacidades = as.integer(v_capacidades)
  
  custo_total = v_capacidades * v_custos
  
  # Rodar o Modelo do Simmer:
  
  entidade <- trajectory("entidade path") %>%
    ## BPM 
    seize("bpm", 1) %>%
    timeout(function() rnorm(1, v_tempos_ciclo[1])) %>%
    release("bpm", 1) %>%
    
    ## Dosagem 
    seize("dosagem", 1) %>%
    timeout(function() rnorm(1, v_tempos_ciclo[2])) %>%
    release("dosagem", 1) %>%
    
    ## Vacuo 
    seize("vacuo", 1) %>%
    timeout(function() rnorm(1, v_tempos_ciclo[3])) %>%
    release("vacuo", 1) %>%
    
    ## BPM 
    seize("mf", 1) %>%
    timeout(function() rnorm(1, v_tempos_ciclo[4])) %>%
    release("mf", 1)
  
    # Restricao teorica:
    # "Takts" individuais:
    takt = v_tempos_ciclo/v_capacidades
  
    pos_restricao = which(takt==max(takt))
    
    taxa_alimentacao = takt[pos_restricao]
    
  envs <- mclapply(1:reps, function(i) {
    simmer(name = "CapacitorSim") %>%
      add_resource("bpm", v_capacidades[1]) %>%
      add_resource("dosagem", v_capacidades[2]) %>%
      add_resource("vacuo", v_capacidades[3]) %>%
      add_resource("mf", v_capacidades[4]) %>%
      add_generator("entidade", entidade, function() taxa_alimentacao) %>%
      run(tempo_sim) %>%
      wrap()
  })
  
  # Criando Estatísticas de Saída:
  arrivals = envs %>%
    get_mon_arrivals %>% 
    dplyr::mutate(waiting_time = end_time - start_time - activity_time)
  
  lead_time = arrivals %>% 
    group_by(replication) %>% 
    summarise(lead_time_rep = mean(end_time - start_time)) %>%
    .$lead_time_rep %>% mean
  
  waiting_time = arrivals %>% 
    group_by(replication) %>% 
    summarise(waiting_time_rep = mean(waiting_time)) %>%
    .$waiting_time_rep %>% mean
  
  producao = sum(arrivals$finished == TRUE) / reps
  
  # Gerando Outputs
  list(
    custo = sum(custo_total),
    lead_time = lead_time,
    producao = producao
  )
   
}

# library(simmer.plot)
# 
# plot(get_mon_arrivals(envs), "waiting_time")
# plot(get_mon_resources(envs))