# Queue Libraries

#library(queuecomputer) # permite modelos complexos, é computacionalmente eficiente.
#library(queueing) # permite modelos markovianos

mm1_eval = function(lambda=1/4, mu=1/3, n=0) {
  model_input = queueing::NewInput.MM1(lambda = lambda, mu = mu, n = n)
  
  queue_model = queueing::QueueingModel(x = model_input)
  
  list(
    Throughput = queue_model$Throughput,
    RO = queue_model$RO,
    VNq = queue_model$VNq,
    Lq = queue_model$Lq,
    Wq = queue_model$Wq,
    VTq = queue_model$VTq,
    L = queue_model$L,
    VN = queue_model$VN,
    W = queue_model$VN,
    VT = queue_model$VT,
    Wqq = queue_model$Wqq,
    Lqq = queue_model$Lqq
    )
}

lake.eval <- function(pollution_limit, samples=100, days=100, b=0.42, q=2, mean=0.02,
                      stdev=0.001, delta=0.98, alpha=0.4, beta=0.08,
                      reliability.threshold=0.9, inertia.threshold=-0.02) {
  pcrit <- uniroot(function(y) y^q/(1+y^q) - b*y, c(0.01, 1.5))$root
  X <- rep(0, days)
  max_P <- 0
  reliability <- 0
  
  for (i in 1:samples) {
    X[1] <- 0
    natural.pollution <- rlnorm(days,
                                log(mean^2/sqrt(stdev^2 + mean^2)),
                                sqrt(log(1+stdev^2/mean^2)))
    
    for (t in 2:days) {
      X[t] <- (1-b)*X[t-1] + X[t-1]^q/(1+X[t-1]^q) + pollution_limit[t] + natural.pollution[t]
    }
    
    max_P <- max_P + max(X) / samples
    reliability <- reliability + sum(X < pcrit) / (samples*days)
  }
  
  utility <- sum(alpha*pollution_limit*delta^(1:days))
  inertia <- sum(diff(pollution_limit) > inertia.threshold) / (days-1)
  
  list(max_P=max_P, utility=utility, inertia=inertia, reliability=reliability)
}

