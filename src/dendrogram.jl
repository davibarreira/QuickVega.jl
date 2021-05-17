"""
_treepositions(hc::Hclust, useheight::Bool, orientation=:vertical)

Function from `StatsPlots.jl` which receives a hierarchical clustering
structure defined on `Clustering.jl` and returns a matrix `xs` and
`ys` with the positions of the branches. The matrices are
4 by `n`.
"""
function _treepositions(hc::Hclust, useheight::Bool, orientation=:vertical)

    order = StatsBase.indexmap(hc.order)
    nodepos = Dict(-i => (float(order[i]), 0.0) for i in hc.order)

    xs = Array{Float64}(undef, 4, size(hc.merges, 1))
    ys = Array{Float64}(undef, 4, size(hc.merges, 1))

    for i in 1:size(hc.merges, 1)
        x1, y1 = nodepos[hc.merges[i, 1]]
        x2, y2 = nodepos[hc.merges[i, 2]]

        xpos = (x1 + x2) / 2
        ypos = useheight ?  (hc.heights[i] / 2) : (max(y1, y2) + 1)
        
        nodepos[i] = (xpos, ypos)
        xs[:, i] .= [x1, x1, x2, x2]
        ys[:, i] .= [y1, ypos, ypos, y2]
    end
    if orientation == :horizontal
        return ys, xs
    else
        return xs, ys
    end
end

"""
dendrogram(hc::Hclust; useheight=true, orientation=:vertical, kwargs...)

Receives a hierarchical clustering from `Clustering.jl` and plots a dendrogram.
The `useheight` specifies if the height of the dendrogram will use the actual
distances when creating the clustering or if it will be uniform.
The `orientation` is self-explanatory.
```julia
# Example
using Clustering
D = rand(10, 10)
D += D'
hc = hclust(D, linkage=:single)
dendrogram(hc)
```
"""
function dendrogram(hc::Hclust; useheight=true, orientation=:vertical, kwargs...)
    xs, ys = treepositions(hc,useheight);
    Xs = reshape(xs,(size(xs)[1]*size(xs)[2]))
    Ys = reshape(ys,(size(ys)[1]*size(ys)[2]));
    Z = repeat(collect(1:size(xs)[2]),inner=size(xs)[1]);
    xticks = []
    for i in Xs
        if isinteger(i)
            if string(Int(i)) in xticks
                push!(xticks,"")
            else
                push!(xticks,string(Int(i)))
            end
        else
            push!(xticks,"")
        end
    end

    p = @vlplot(data=df,
                layer=[{
                    mark=:line,
                    x={field=:x,type="ordinal",
                        axis={grid=false,labels=false,values=collect(1:length(hc.order)),title=false}},
                    y={field=:y},
                    detail=:c
                    },
                    {
                    mark={type=:text, fontSize=8, align="right"},
                    x={field=:x,type="ordinal"},
                    y={value=410},
                    text={field=:xticks,type="nominal"}
                    }
    ])
    updatePlot!(p;defaultParameters...)
    updatePlot!(p;kwargs...)
    return p
end