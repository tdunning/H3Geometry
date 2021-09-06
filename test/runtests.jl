using Test
using H3
using H3Geometry
using LibGEOS
using GeoInterface

# verify basics
@test H3Geometry.geoToH3(42, -110, 6) == H3.API.geoToH3(H3.Lib.GeoCoord(deg2rad(42.0), deg2rad(-110.0)), 6)
@test H3Geometry.geoToH3([42.0, -110], 6) == H3.API.geoToH3(H3.Lib.GeoCoord(deg2rad(42.0), deg2rad(-110.0)), 6)
@test H3Geometry.geoToH3(LibGEOS.Point(42.0, -110), 6) == H3.API.geoToH3(H3.Lib.GeoCoord(deg2rad(42.0), deg2rad(-110.0)), 6)

# verify that H3.API.geoToH3 is overloaded
@test H3.API.geoToH3(42, -110, 6) == H3.API.geoToH3(H3.Lib.GeoCoord(deg2rad(42.0), deg2rad(-110.0)), 6)

# validate that reasonable dot usage works
@test begin
    @info "Convert combined with broadcast"
    p = coordinates(boundary(LibGEOS.Polygon([[[0.0, 0.0], [1, 1], [2, 0], [0, 0]]])))
    H3.API.geoToH3.(p, 5) == [0x085754e67fffffff, 0x0857541affffffff, 0x0857542b7fffffff, 0x085754e67fffffff]
end

# verify that a hexagon appears in roughly the right box and has the right shape
@test begin
    @info "Hexagonal sanity check"
    p0 = H3.API.geoToH3(46, -110,5)
    p1 = H3Geometry.h3ToPolygon(p0)
    p2 = LibGEOS.Polygon([[[45.85, -110.15], [46.1, -110.15], [46.1, -109.85], [45.85, -109.85], [45.85, -110.15]]])
    length(coordinates(boundary(p1))) == 7 && area(difference(p1, p2)) == 0.0 && area(p1) / area(p2) > 0.1
end

# verify that we can do unions of H3index values
@test begin
    @info "Unions of H3index"
    p0 = H3.API.geoToH3(46, -110, 5)
    p1 = H3Geometry.h3ToPolygon(p0)
    p2 = H3.API.kRing(p0, 1)
    p3 = H3Geometry.h3ToPolygon(p2)
    p4 = H3Geometry.h3ToPolygon(H3.API.geoToH3(46, -110, 4))
    isapprox(area(p3), 7 * area(p1), atol=1e-4) && isapprox(area(p3), area(p4), atol=1e-3)
end

# verify minimal overspray for polyfill with cover=0
@test begin
    @info "Polyfill overspray"
    p0 = LibGEOS.Polygon([[[45.5, -110.2], [46.1, -110.2], [46.1, -109.85], [45.5, -109.85], [45.5, -110.2]]])
    p1 = H3Geometry.polyfill(p0, 6, cover=0)
    ratio =  area(H3Geometry.h3ToPolygon(p1)) / area(p0)
    ratio < 1 && ratio >= 0.99
end

# verify minimal underspray for polyfill with cover=1.2
@test begin
    @info "Polyfill underspray"
    p0 = LibGEOS.Polygon([[[45.5, -110.2], [46.1, -110.2], [46.1, -109.85], [45.5, -109.85], [45.5, -110.2]]])
    p1 = H3Geometry.h3ToPolygon(H3Geometry.polyfill(p0, 7, cover=1.2))
    ratio =  area(p1) / area(p0)
    a1 = area(difference(p1, p0))
    a2 = area(difference(p0, p1))
    ratio > 1.1 && a1 < 0.15 && a2 < 1e-9
end
