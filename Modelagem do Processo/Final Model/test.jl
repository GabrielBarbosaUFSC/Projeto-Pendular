using ControlSystems
using Plots; plotly()

setPlotScale("dB")

H = tf([1], [1/200, 1])

bodeplot(H)