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
or manipulated using [LibGEOS]
