using Printf
using Dates

function save_matrix_to_array_c(list_matrix, list_label, filename)
    file_name = filename*".txt"
    open(file_name, "w") do file
        date = Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS")
        date_s = "// date: "*date*"\n"
        write(file, date_s)
        write(file, "\n\n")

        for k in eachindex(list_matrix)
            matrix = list_matrix[k]
            label = list_label[k]

            n_rows = length(matrix[:,1])
            n_colums = length(matrix[1,:])
            n_elements = length(matrix)

            sn_rows = "// n_rows: "*string(n_rows)*"\n"
            sn_colums = "// n_colu: "*string(n_colums)*"\n"
            selements = "// n_elem: "*string(n_elements)*"\n"
    
            write(file, sn_rows)
            write(file, sn_colums)
            write(file, selements)
    
            s_variable = "\ndouble "*label*"["*string(n_elements)*"] = {\n"
            write(file, s_variable)
    
            counter = 0
            for i in eachrow(matrix)
                write(file, "\t")
                for j in eachindex(i)
                    counter += 1;
                    s = ""
                    if counter == n_elements
                        s = @sprintf("%.16e", i[j])
                    else 
                        s = @sprintf("%.16e, ", i[j])
                    end
                    write(file, s)
                end
                write(file, "\n")
            end
            write(file, "};\n\n\n\n")
        end
    end
end

A = [1 2 3; 4 5 6]
B = [7 8; 9 10; 11 12]

save_matrix_to_array_c([A, B], ["A", "B"], "test")