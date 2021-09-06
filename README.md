# H3Geometry

This package smooths off some of the rough edges of the
[H3](https://github.com/wookay/H3.jl) package by allowing you to refer to points
in latitude/longitude as well as using the abstract geometrical objects of
[GeoInterface](https://github.com/JuliaGeo/GeoInterface.jl).

The most important capability in H3Geometry is the ability to cover arbitrary
polygons with `H3indexes` accurately. The polyfill function from H3 severely
undercovers the polygon you are filling. The version here allows you to
precisely control the tradeoff between over and under coverage.

This package also can convert `H3indexes` into polygons that can be plotted
or manipulated using [LibGEOS](https://github.com/JuliaGeo/LibGEOS.jl)

# Examples

You can use positions expressed as latitude and longitude in decimal degrees and use broadcast:
```
julia> geoToH3(42, -110, 6)
0x08626b3cafffffff

julia> poly = LibGEOS.Polygon([[[0.0,0.0],[1,1],[2,0],[0,0]]])
julia> H3.API.geoToH3.(coordinates(boundary(poly)), 5)
4-element Vector{UInt64}:
 0x085754e67fffffff
 0x0857541affffffff
 0x0857542b7fffffff
 0x085754e67fffffff
```

You can also convert an `H3Index` into a polygon. Converting a list of indexes gives you the union of those polygons:
```
julia> using H3, H3Geometry, Plots
julia> x = [rand(2) + [42, -110] for i in 1:10] 
julia> x = [rand(2) + [42, -110] for i in 1:10] 
10-element Vector{Vector{Float64}}:
 [42.93118830985577, -109.96129703301348]
 [42.04374657317701, -109.74858537818785]
...
 [42.93898540906256, -109.56166169057441]
julia> H3.API.geoToH3.(x, 5)
10-element Vector{UInt64}:
 0x08526b053fffffff
 0x08526b3c7fffffff
...
 0x08526b01bfffffff

 julia> plot()
 julia> for i in 3:6
       plot!(H3Geometry.h3ToPolygon(H3.API.geoToH3.(x, i)))
       end
julia> gui()
```

The polyfill function is also easier to use and Julian now. It is extended to allow a variable amount of over-coverage to let you ensure complete coverage of the underlying shape. Note that you can't reasonably poly-fill self-intersecting polygons.

```
julia> x = [rand(2) + [42, -110] for i in 1:6]
6-element Vector{Vector{Float64}}:
 [42.79713730410485, -109.37352389704235]
 [42.91411302382121, -109.99439297771008]
...
 [42.723627596109985, -109.26722820551728]

julia> push!(x, x[1])
7-element Vector{Vector{Float64}}:
 [42.79713730410485, -109.37352389704235]
 ...
 
julia> p = buffer(LibGEOS.Polygon([x]), 0)
LibGEOS.Polygon(Ptr{Nothing} @0x00007faa211bf5b0)

julia> plot()
julia> for i in 4:8
               plot!(H3Geometry.h3ToPolygon(H3Geometry.polyfill(p,i)))
           end
julia> gui()
```

julia> for i in 4:8
       plot!(H3Geometry.h3ToPolygon(H3Geometry.polyfill(p,i)))
       end

julia> plot!(p)
```

