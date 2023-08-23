using CSV
using DataFrames
using Plots; plotly()
using Statistics

function get_data(path)
    #path = "M1.csv"
    filepath = joinpath(@__DIR__, path)
    dataframe = CSV.read(filepath, DataFrame)
    n = dataframe[:,1]
    time = dataframe[:,2]/1e6
    raw_accel = dataframe[:,3]
    raw_gyro = dataframe[:,4]
    kalman_accel = dataframe[:,5]
    return n, time, raw_accel, raw_gyro, kalman_accel
end

n, time, raw_theta, raw_gyro, kalman_theta= get_data("accel.csv")

dtime = zeros(length(n)-1)
for i in range(2,length(n))
    dtime[i-1] = time[i] - time[i-1]
end

mean(dtime)

plot(dtime)

mean(kalman_theta)

begin
    p1 = plot(time, [30/pi*raw_theta 180/pi*kalman_theta])
    p2 = plot(time, raw_gyro)
    p3 = plot(time, [180/pi*kalman_theta raw_gyro])
    plot(p1, p2, p3, layout=(3,1), size=(720,480))  
end

plot(time, [theta_predict 180/pi*raw_theta])

begin
    Q_angle = 0.001
    Q_bias = 0.002
    R_measure = 0.07
    angle = -3.762903
    bias = 0
    P = zeros(2,2)

    function update_kalman(dt, ω, read)
        global angle, bias, Q_angle, Q_bias, R_measure, P
        rate = ω - bias
        angle += dt*rate
        
        P[1,1] += dt*(dt*P[2,2] - P[1,2] - P[2,1] + Q_angle)
        P[1,2] -= dt*P[2,2]
        P[2,1] -= dt*P[2,2]
        P[2,2] += Q_bias*dt
    
        S = P[1,1] + R_measure
        K = P[:,1]/S
        y = read - angle
        angle += K[1]*y
        bias += K[1]*y
    
        P11_temp = P[1,1]
        P12_temp = P[1,2]
    
        P[1,1] -= K[1]*P11_temp
        P[1,2] -= K[1]*P12_temp
        P[2,1] -= K[2]*P11_temp
        P[2,2] -= K[2]*P12_temp
        return angle
    end
    
    angle = -3.762903
    theta_mykalman = zeros(length(dtime)+1)
    theta_mykalman[1] = -3.762903
    for i in eachindex(dtime)
        theta_mykalman[i+1] = update_kalman(dtime[i], raw_gyro[i+1], 180/pi*raw_theta[i+1])
    end     

    theta_predict = zeros(length(dtime)+1)
    theta_predict[1] = -3.762903
    for i in eachindex(dtime)
        theta_predict[i+1] = theta_predict[i]+raw_gyro[i+1]*dtime[i]
    end
    
    plot(time, [theta_mykalman, 180/pi*kalman_theta, 180/pi*raw_theta, theta_predict])
end
 

