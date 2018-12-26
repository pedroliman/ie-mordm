
library(queueing)

# Model From:
# For example, imagine the urgent-treatment box of a hospital.  Patients arrive at the rate of 10
# patients/hour. A doctor examines each patient and may provide treatment and then send the patient
# home, or derive the patient to a specialist (orthopaedist, cardiologist, etc.), who in turn may request
# tests (blood analysis, radiography, etc.), and then send the patient home or recommend hospitalisation.
# In the latter case(assuming there are beds available), treatment will be provided, more checks and tests
# may be required and, eventually, the patient will leave (not always to go home).
# In this case, the model used is a single-class Open Jackson network, with five nodes: general doctor,
# orthopaedist, cardiologist, checks and tests box (composed of 15 technicians) and hospitalised (with
#                                                                                                 space for any number of patients). Except for visiting the general physician, in no case is a patient
# allowed to directly enter another node
# https://journal.r-project.org/archive/2017/RJ-2017-051/RJ-2017-051.pdf

data <- c(0, 0.3, 0.2, 0, 0, 0, 0, 0, 0.7, 0.1, 0, 0, 0, 0.8, 0.15, 0, 0.4, 0.3, 0, 0.3)
prob <- matrix(data=data, byrow = TRUE, nrow = 5, ncol=5)
gd  <- NewInput.MM1(lambda=10, mu=25, n=0)
ort <- NewInput.MM1(lambda=0,  mu=18, n=0)
car <- NewInput.MM1(lambda=0,  mu=20, n=0)
tb  <- NewInput.MMC(lambda=0, mu=12, c=15, n=0)
hos <- NewInput.MMInf(lambda=0, mu=0.012, n=0)
hospital <- NewInput.OJN(prob=prob, gd, ort, car, tb, hos)

CheckInput(hospital)
m_hospital <- QueueingModel(hospital)

m_hospital$Throughput
m_hospital$L
m_hospital$W

summary(m_hospital)

## Two Classes:
# Multi Class Open Network Papers:
# http://www.mit.edu/~jnt/Papers/J049-94-yp-polyh.pdf
# http://www.cse.cuhk.edu.hk/~cslui/CSC5420/queueing_network_beamer.pdf
# http://www.pitt.edu/~dtipper/2130/2130_Slides5.pdf
# https://waset.org/publications/208/a-multiclass-bcmp-queueing-modeling-and-simulation-based-road-traffic-flow-analysis
# http://shodhganga.inflibnet.ac.in/bitstream/10603/173958/7/07_chapter2.pdf
# https://homes.cs.washington.edu/~lazowska/qsp/
# Classes
classes <- 2
# Taxa de Chegada das classes
vLambda <- c(2, 10)
# Número de Nós da Rede
nodes   <- 5
# Tipo dos Nós - Q - Fila; D - Delay.
vType     <- c("Q", "Q", "Q", "Q", "D")
# Número Médio de visitas por Nó
vHigh   <- c(2, 4, 2, 6, 2)
vNorm   <- c(1, 2, 1, 3, 0.5)
vVisit  <- matrix(data=c(vHigh, vNorm), nrow=classes, ncol=nodes, byrow = TRUE)
# Tempo Médio de Atendimento por Classe
sHigh    <- c(1/100, 1/250, 1/300, 1/600, 1/5)
sNorm    <- c(1/90, 1/150, 1/200, 1/300, 1/3)
vService <-matrix(data=c(sHigh, sNorm), nrow=2, ncol=5, byrow = TRUE)

cl_hosp <- NewInput.MCON(classes, vLambda, nodes, vType, vVisit, vService)

CheckInput(cl_hosp)
m_cl_hosp <- QueueingModel(cl_hosp)
print(summary(m_cl_hosp), digits = 2)
