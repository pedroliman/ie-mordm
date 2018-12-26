# -*- coding: utf-8 -*-
"""
Created on Tue Dec 25 17:35:02 2018

@author: Pedro Lima
"""

from rhodium import *
from rhodium.rbridge import RModel

## Original Analisis - Lake Model
model = RModel("lake.R", "lake.eval", RCMD=r"/usr/lib/R/bin/R")

# The parameter names must match the R arguments exactly
model.parameters = [Parameter("pollution_limit"),
                    Parameter("b"),
                    Parameter("q"),
                    Parameter("mean"),
                    Parameter("stdev"),
                    Parameter("delta")]

# List all outputs from the R function, which should return these values either as
# an unnamed array in the given order (e.g., c(max_P, utility, ...)) or as a named
# list (e.g., list(max_P=..., utility=..., ...)).
model.responses = [Response("max_P", Response.MINIMIZE),
                   Response("utility", Response.MAXIMIZE),
                   Response("inertia", Response.MAXIMIZE),
                   Response("reliability", Response.MAXIMIZE)]

# Specify the levers
model.levers = [RealLever("pollution_limit", 0.0, 0.1, length=100)]
output = optimize(model, "NSGAII", 1000)
print(output)

## There's an error on running the model

# Queue Model
# Provide the R file and function name
model = RModel("queue_model.R", "mm1_eval", RCMD=r"/usr/lib/R/bin/R")

# The parameter names must match the R arguments exactly
model.parameters = [Parameter("lambda"),
                    Parameter("mu"),
                    Parameter("n")]

# List all outputs from the R function, which should return these values either as
# an unnamed array in the given order (e.g., c(max_P, utility, ...)) or as a named
# list (e.g., list(max_P=..., utility=..., ...)).
model.responses = [Response("RO_ResourceUtilization", Response.MAXIMIZE),
                   Response("Lq_MeanNumberInQueue", Response.MINIMIZE)]

# Specify the levers
model.levers = [RealLever("lambda", 1/200, 2, length=1),
                RealLever("mu", 1/200, 2, length=1)]


# Optimize the model using Rhodium
output = optimize(model, "NSGAII", 10000)
print(output)

### Analysing Outputs

# plotting options
%matplotlib inline
sns.set()
sns.set_style('darkgrid')

print ("Found", len(output), "optimal policies!")

data_frame_output = output.as_dataframe()

fig = scatter2d(model, output)

scatter3d(model, output)

plt.show()



fig = pairs(model, output)

fig = parallel_coordinates(model, output, colormap="rainbow", target="top")

fig = parallel_coordinates(model, output, target="top",
                           brush=[Brush("Lq_MeanNumberInQueue > 30"), Brush("Lq_MeanNumberInQueue <= 30")])

# Kernel density estimation plots show density contours for samples. By
# default, it will show the density of all sampled points
kdeplot(model, output, x="Lq_MeanNumberInQueue", y="RO_ResourceUtilization")
plt.show()
 
# Alternatively, we can show the density of all points meeting one or more
# conditions
kdeplot(model, output, x="Lq_MeanNumberInQueue", y="RO_ResourceUtilization", brush=["Lq_MeanNumberInQueue <= 50"], alpha=0.8)
plt.show()