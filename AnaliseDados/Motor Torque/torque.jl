using CSV
using DataFrames
using Plots; plotly()
using LsqFit

function get_data(path)
    filepath = joinpath(@__DIR__, path)
    dataframe = CSV.read(filepath, DataFrame)
    i = dataframe[:,1]
    dtime = dataframe[:,2]/1e6
    return i, dtime
end

i, dtimeM3 = get_data("cargafullm3_2.csv")
i, dtimeM5 = get_data("cargafullm5_2.csv")

begin
    t1 = zeros(length(dtimeM3))
    for i in eachindex(dtimeM3)
        if i != 1
            t1[i] = t1[i-1] + dtimeM3[i]
        else
            t1[i] = dtimeM3[1]
        end
    end    
end
begin
    t2 = zeros(length(dtimeM5))
    for i in eachindex(dtimeM5)
        if i != 1
            t2[i] = t2[i-1] + dtimeM5[i]
        else
            t2[i] = dtimeM5[1]
        end
    end    
end




ωM3 = @. 1/dtimeM3
ωM5 = @. 1/dtimeM5

begin
    plot([t1,t2], [ωM3,ωM5])
end
