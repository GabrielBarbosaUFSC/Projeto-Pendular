from scipy.integrate import odeint
import numpy as np
import matplotlib.pyplot as plt
import math

g = 9.81
l = 0.1

def model(y, t):
    dtheta = y[0]
    theta = y[1]
    dydt0 = -g/l*math.sin(theta)
    dydt1 = dtheta
    return [dydt0, dydt1]

#initial condition
y0 = [0, math.pi/2]

#time points 
t = np.linspace(0,10, 10000)
y = odeint(model, y0, t)

#plot
plt.plot(t, y)
plt.show()