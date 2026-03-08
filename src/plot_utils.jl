using Gadfly
using StatsPlots

function build_results_plot(population, config_file, fitness_function)
    time = Dates.format(now(), "HH:MM:SS")
    outcome_file_name = "$(config_file)_$(fitness_function.fitness_function)"
    p = Gadfly.plot(
        population,
        x=:Generations, y=:F_Values,
        Geom.line, Guide.title(outcome_file_name),
        Guide.manual_color_key("Legend", ["Fitness values"])
    );
    img = PNG("./data/Plots/$(outcome_file_name)_$(time).png", 6inch, 4inch)
    draw(img, p);
end

