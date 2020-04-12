using MultiplesOfPi
using Test

@testset "Constructor" begin
    @testset "PiTimes" begin
        @test PiTimes(1) ≈ π
        @test PiTimes(1.5) ≈ 1.5*pi
        @test PiTimes(1//2) ≈ π/2

        @test PiTimes(1) === Pi
        @test Pi == π
        @test π == Pi
        @test 2π ≈ 2Pi

        @test PiTimes(pi) === PiTimes(PiTimes(1))
        @test PiTimes(PiTimes(pi)) === PiTimes(PiTimes(PiTimes(1)))
    end

    @testset "PiExpTimes" begin
        @test PiExpTimes{-1}(1) ≈ 1/π
        @test PiExpTimes{-2}(2) ≈ 2/π^2

        @test PiExpTimes{2}(Pi^2) === Pi^4
        @test PiExpTimes{-2}(Pi^2) === 1
        @test PiExpTimes{-2}(1.0Pi^2) === 1.0
        @test PiExpTimes{2}(Pi^-2) === 1.0
        @test PiExpTimes{2,Int}(Pi^2) === Pi^4
        @test PiExpTimes{2,Float64}(Pi^2) === 1.0Pi^4

        @test PiTimes(pi) === PiExpTimes{2}(1)
        @test PiExpTimes{2}(pi) === PiExpTimes{3}(1)

        @test PiExpTimes{2}(π) == PiExpTimes{3}(1)

        @test PiExpTimes{2}(PiExpTimes{3}(1)) === Pi^5
        
        @test float(PiExpTimes{2}(2)) === 2*pi*pi

        @testset "PiExpTimes{0}" begin
            @test PiExpTimes{0}(3) === 3
            @test PiExpTimes{0}(3.0) === 3.0
            @test PiExpTimes{0}(Pi) === Pi
            @test float(PiExpTimes{0,Float64}(3.0)) === 3.0
            @test float(PiExpTimes{0,Int}(3)) === 3.0
        end

    end
end

@testset "Ordering" begin
    @testset "inequality" begin
        @testset "PiTimes" begin
            @test PiTimes(1) < 4
            @test PiTimes(2) > 4
            @test PiTimes(2) > π
            @test PiTimes(2) < PiTimes(4)
            @test !(Pi < π)
            @test !(π < Pi)
        end
        @testset "PiExpTimes" begin
            @test PiExpTimes{2}(3) < PiExpTimes{2}(4)
            @test PiExpTimes{1}(3) < PiExpTimes{2}(3)
            @test PiExpTimes{1}(3) < PiExpTimes{2}(3.5)
            @test PiTimes(3) < PiExpTimes{2}(3)
            @test π < PiExpTimes{2}(1)
            @test !(PiExpTimes{2}(1) < π)
            @test 1 < PiExpTimes{2}(1)
            @test PiExpTimes{2}(1) > π 
            @test PiExpTimes{2}(1) > 1
            @test PiExpTimes{0}(1) < 2
            @test PiExpTimes{0}(1) < π
        end
    end
    @testset "equality" begin
        @testset "PiTimes" begin
            @test Pi == π
            @test π == Pi
            @test PiTimes(2) == PiTimes(2)
            @test PiTimes(0) == 0
            @test 0 == PiTimes(0)
            @test Pi != 2Pi
            @test Pi != 4
        end
        @testset "PiExpTimes" begin
            Pi² = PiExpTimes{2}(1)
            Pi³ = PiExpTimes{3}(1)

            z² = PiExpTimes{2}(0)
            z³ = PiExpTimes{3}(0)

            @test Pi² == Pi²
            @test Pi² == π^2
            @test π^2 == Pi²
            
            @test Pi² != 3
            @test 3 != Pi²
            
            @test Pi² != Pi
            @test Pi  != Pi²

            @test Pi² != Pi³
            @test Pi³ != Pi²

            @test Pi² != π
            @test π != Pi²

            @test z² == z³
            @test z² == 0
        end
    end
end

@testset "sign" begin
    @testset "PiTimes" begin
        @testset "sign" begin
            @test sign(Pi) == 1
            @test sign(PiTimes(3.4)) == 1.0
            @test sign(PiTimes(0.0)) == 0.0
            @test sign(PiTimes(-0.0)) == -0.0
            @test sign(PiTimes(1//2)) == 1//1

        end
        @testset "signbit" begin
            @test !signbit(Pi)
            @test !signbit(PiTimes(0))
            @test !signbit(PiTimes(-0))
            @test signbit(PiTimes(-1))
            @test signbit(PiTimes(-0.0))
            @test !signbit(PiTimes(0.0))
        end
    end
    @testset "PiExpTimes" begin
        @testset "sign" begin
            @test sign(PiExpTimes{2}(1)) == 1
            @test sign(PiExpTimes{2}(3.4)) == 1.0
            @test sign(PiExpTimes{2}(0.0)) == 0.0
            @test sign(PiExpTimes{2}(-0.0)) == -0.0
            @test sign(PiExpTimes{2}(1//2)) == 1//1
        end
        @testset "signbit" begin
            @test !signbit(PiExpTimes{2}(1))
            @test !signbit(PiExpTimes{2}(0))
            @test !signbit(PiExpTimes{2}(-0))
            @test signbit(PiExpTimes{2}(-1))
            @test signbit(PiExpTimes{2}(-0.0))
            @test !signbit(PiExpTimes{2}(0.0))
        end
    end
end

@testset "zero and one" begin
    @testset "one" begin
        for N = -5:5
            N == 0 && continue
            for T in (Float16,Float32,Float64,Int8,Int16,Int32,Int64,Int128,BigInt,BigFloat)
                @test one(PiExpTimes{N,T}) === true
                @test one(PiExpTimes{N}(zero(T))) === true
            end
        end
        for T in (Float16,Float32,Float64,Int8,Int16,Int32,Int64,Int128)
            @test one(PiTimes(zero(T))) === true
            @test one(PiExpTimes{0,T}) === one(T)
            @test one(PiExpTimes{0}(zero(T))) === one(T)
        end
        for T in (BigInt,BigFloat)
            @test one(PiTimes(zero(T))) === true
            @test one(PiExpTimes{0,T}) == one(T)
            @test one(PiExpTimes{0}(zero(T))) == one(T)
        end
        @test one(Pi) === true
    end
    @testset "zero" begin
        @test zero(Pi) === PiTimes(0) == 0
        @test zero(typeof(Pi)) === PiTimes(0) == 0
        for N = -5:5
            N == 0 && continue
            for T in (Float16,Float32,Float64,Int8,Int16,Int32,Int64,Int128)
                @test zero(PiExpTimes{N,T}) isa PiExpTimes{N,T}
                @test zero(PiExpTimes{N,T}(1)) isa PiExpTimes{N,T}
                @test zero(PiExpTimes{N,T}(1)) === PiExpTimes{N,T}(0)
            end
            for T in (BigInt,BigFloat)
                @test zero(PiExpTimes{N,T}) isa PiExpTimes{N,T}
                @test zero(PiExpTimes{N,T}(1)) isa PiExpTimes{N,T}
                @test zero(PiExpTimes{N,T}(1)) == PiExpTimes{N,T}(0)
            end
        end
        for T in (Float16,Float32,Float64,Int8,Int16,Int32,Int64,Int128)
            @test zero(PiExpTimes{0,T}) isa T
            @test zero(PiExpTimes{0,T}(1)) isa T
            @test zero(PiExpTimes{0,T}(1)) === zero(T)
        end
        for T in (BigInt,BigFloat)
            @test zero(PiExpTimes{0,T}) isa T
            @test zero(PiExpTimes{0,T}(1)) isa T
            @test zero(PiExpTimes{0,T}(1)) == zero(T)
        end
    end
end

@testset "conversion" begin
    @testset "promote_type" begin
        @testset "PiExpTimes and PiExpTimes" begin
            @testset "PiTimes and PiTimes" begin
                for t in (Int8, Int16, Int32, Int64, Int128, Bool, UInt8, UInt16, UInt32, UInt64, UInt128)
                        @test promote_type(PiTimes{Float16},PiTimes{t}) === PiTimes{Float16}
                        @test promote_type(PiTimes{t},PiTimes{Float16}) === PiTimes{Float16}
                end
                for t1 in (Float32, Float64)
                    for t2 in (Int8, Int16, Int32, Int64, Bool, UInt8, UInt16, UInt32, UInt64)
                        @test promote_type(PiTimes{t1},PiTimes{t2}) === PiTimes{t1}
                        @test promote_type(PiTimes{t2},PiTimes{t1}) === PiTimes{t1}
                    end
                end
            end
            @testset "PiExpTimes{2} and PiExpTimes{2}" begin
                for t in (Int8, Int16, Int32, Int64, Int128, Bool, UInt8, UInt16, UInt32, UInt64, UInt128)
                        @test promote_type(PiExpTimes{2,Float16},PiExpTimes{2,t}) === PiExpTimes{2,Float16}
                        @test promote_type(PiExpTimes{2,t},PiExpTimes{2,Float16}) === PiExpTimes{2,Float16}
                end
                for t1 in (Float32, Float64)
                    for t2 in (Int8, Int16, Int32, Int64, Bool, UInt8, UInt16, UInt32, UInt64)
                        @test promote_type(PiExpTimes{2,t1},PiExpTimes{2,t2}) === PiExpTimes{2,t1}
                        @test promote_type(PiExpTimes{2,t2},PiExpTimes{2,t1}) === PiExpTimes{2,t1}
                    end
                end
            end
            @testset "PiExpTimes{2} and PiTimes" begin
                for t in (Int8, Int16, Int32, Int64, Int128, Bool, UInt8, UInt16, UInt32, UInt64, UInt128)
                        @test promote_type(PiExpTimes{2,Float16},PiTimes{t}) === Float64
                        @test promote_type(PiTimes{t},PiExpTimes{2,Float16}) === Float64
                end
                for t1 in (Float32, Float64)
                    for t2 in (Int8, Int16, Int32, Int64, Bool, UInt8, UInt16, UInt32, UInt64)
                        @test promote_type(PiExpTimes{2,t1},PiTimes{t2}) === Float64
                        @test promote_type(PiTimes{t2},PiExpTimes{2,t1}) === Float64
                    end
                end
            end
        end

        @testset "PiExpTimes and Irrational" begin
            @test promote_type(PiTimes{Int},Irrational{:π}) === PiTimes{Int}
            @test promote_type(Irrational{:π},PiTimes{Int}) === PiTimes{Int}
            @test promote_type(PiTimes{Float64},Irrational{:π}) === PiTimes{Float64}
            @test promote_type(Irrational{:π},PiTimes{Float64}) === PiTimes{Float64}
        end
        
        @testset "Complex{PiExpTimes}" begin
            @testset "Complex{PiTimes} and Irrational{:π}" begin
                @test promote_type(Complex{PiTimes{Int}},Irrational{:π}) === Complex{PiTimes{Int}}
                @test promote_type(Irrational{:π},Complex{PiTimes{Int}}) === Complex{PiTimes{Int}}
                @test promote_type(Complex{PiTimes{Float64}},Irrational{:π}) === Complex{PiTimes{Float64}}
                @test promote_type(Irrational{:π},Complex{PiTimes{Float64}}) === Complex{PiTimes{Float64}}
            end
            @testset "Complex{PiExpTimes} and Irrational{:π}" begin
                @test promote_type(Complex{PiExpTimes{2,Int}},Irrational{:π}) === Complex{Float64}
                @test promote_type(Irrational{:π},Complex{PiExpTimes{2,Int}}) === Complex{Float64}
                @test promote_type(Complex{PiExpTimes{2,Float64}},Irrational{:π}) === Complex{Float64}
                @test promote_type(Irrational{:π},Complex{PiExpTimes{2,Float64}}) === Complex{Float64}
            end
        end
    end
    @testset "convert" begin
        @testset "PiExpTimes to float" begin
            @testset "PiTimes" begin
                @test convert(Float64,PiTimes(1)) === Float64(π)
                @test Float64(PiTimes(1)) === Float64(1)*π
                @test convert(Float64,PiTimes(2)) === Float64(2π)
                @test Float64(PiTimes(2)) === Float64(2)*π
                @test convert(BigFloat,PiTimes(1)) == BigFloat(1)*π
                @test BigFloat(PiTimes(1)) == BigFloat(1)*π
                @test convert(Float32,PiTimes(1)) === Float32(1)*π
                @test Float32(PiTimes(1)) === Float32(1)*π
                @test convert(Float16,PiTimes(1)) === Float16(1)*π
                @test Float16(PiTimes(1)) === Float16(1)*π
            end
            @testset "PiExpTimes" begin
                @test convert(Float64,PiExpTimes{2}(1)) === Float64(π^2)
                @test Float64(PiExpTimes{2}(1)) === Float64(1)*π^2
                @test convert(Float64,PiExpTimes{2}(2)) === Float64(2π^2)
                @test Float64(PiExpTimes{2}(2)) === Float64(2)*π^2
                @test convert(BigFloat,PiExpTimes{2}(1)) == BigFloat(1)*π*π
                @test BigFloat(PiExpTimes{2}(1)) == BigFloat(1)*π*π
                @test convert(Float32,PiExpTimes{2}(1)) === Float32(1)*π*π
                @test Float32(PiExpTimes{2}(1)) === Float32(1)*π*π
                @test convert(Float16,PiExpTimes{2}(1)) === Float16(1)*π*π
                @test Float16(PiExpTimes{2}(1)) === Float16(1)*π*π
            end
        end
        @testset "Real to PiExpTimes" begin
            @testset "Irrational to PiTimes" begin
                @test convert(PiTimes{Int},π) === PiTimes(1)
                @test convert(PiTimes{Float64},π) === PiTimes(1.0)
                @test convert(PiTimes,π) === PiTimes(1.0)
            end
            @testset "Irrational to PiExpTimes" begin
                @test convert(PiExpTimes{2},π) === PiExpTimes{2}(1/π)
                @test convert(PiExpTimes{2,Float64},π) === PiExpTimes{2}(Float64(1/π))
            end

            @testset "Int and Float to PiExpTimes" begin
                @testset "PiTimes" begin
                    @test convert(PiTimes,2) === PiTimes(2/π)
                    for t in (Float16,Float32,Float64)
                        @test convert(PiTimes{t},2) === PiTimes{t}(2/π)
                        @test convert(PiTimes{t},2.0) === PiTimes{t}(2.0/π)
                    end
                    convert(PiTimes{BigFloat},2) === PiTimes{BigFloat}(2/π)
                    convert(PiTimes{BigFloat},2.0) === PiTimes{BigFloat}(2.0/π)
                end
                @testset "PiExpTimes" begin
                    @test convert(PiExpTimes{2},2) === PiExpTimes{2}(2/π^2)
                    for t in (Float16,Float32,Float64)
                        @test convert(PiExpTimes{2,t},2) === PiExpTimes{2,t}(2/π^2)
                        @test convert(PiExpTimes{2,t},2.0) === PiExpTimes{2,t}(2.0/π^2)
                    end
                    convert(PiExpTimes{2,BigFloat},2) === PiExpTimes{2,BigFloat}(2/π^2)
                    convert(PiExpTimes{2,BigFloat},2.0) === PiExpTimes{2,BigFloat}(2.0/π^2)
                end
            end
        end
        @testset "PiExpTimes to PiExpTimes" begin
            @testset "PiTimes to PiTimes" begin
                for t in (Int8, Int16, Int32, Int64, Int128, Bool, UInt8, UInt16, UInt32, UInt64, UInt128)
                    @test convert(PiTimes{Float16},PiTimes{t}(0)) === PiTimes(Float16(0))
                end
                for t1 in (Float32, Float64)
                    for t2 in (Int8, Int16, Int32, Int64, Bool, UInt8, UInt16, UInt32, UInt64)
                        @test convert(PiTimes{t1},PiTimes{t2}(0)) === PiTimes(t1(0))
                    end
                end
            end
            @testset "PiExpTimes to PiExpTimes{2}" begin
                @test convert(PiExpTimes{2},Pi) === PiExpTimes{2}(1/π)
                @test convert(PiExpTimes{2},Pi^2) === Pi^2
                @test convert(PiExpTimes{2,Float64},Pi^2) === 1.0*Pi^2
                @test convert(PiExpTimes{2,Int},Pi^2) === Pi^2
                @test convert(PiExpTimes{2},Pi^3) === PiExpTimes{2}(float(π))
                @test convert(PiExpTimes{2,Float64},Pi) === PiExpTimes{2}(1/π)
                @test convert(PiExpTimes{2,Float64},Pi^2) === PiExpTimes{2}(1.0)
                @test convert(PiExpTimes{2,Float64},Pi^3) === PiExpTimes{2}(float(π))
            end
        end
        @testset "Complex" begin
            @test Complex(Pi,Pi) === Pi + im*Pi
            @test Complex(Pi^2,Pi^2) === Pi^2 + im*Pi^2
            @test Complex(Pi^2,Pi) === π^2 + im*π
            @test Complex(Pi,π) === Pi + im*Pi
            @test Complex(π,Pi) === Pi + im*Pi
        end
    end
end

@testset "arithmetic" begin
    p = PiTimes(3)
    q = PiTimes(4)
    r = PiExpTimes{2}(4)

    @testset "negation" begin
        @test -p isa PiTimes{Int}
        @test -r isa PiExpTimes{2,Int}
        @test -p === PiTimes(-p.x)
        @test -r === PiExpTimes{2}(-r.x)
    end 

    @testset "addition" begin
        @test p + p === PiTimes(2p.x)
        @test p + q === PiTimes(p.x + q.x)
        @test r + r === PiExpTimes{2}(2r.x)
        @test p + r === float(p) + float(r)
    end

    @testset "subtraction" begin
        @test p - p === PiTimes(0) == 0
        @test p - q === PiTimes(p.x - q.x)
        @test r - r === PiExpTimes{2}(zero(r.x)) == 0
        @test p - r === float(p) - float(r)
    end

    @testset "multiplication" begin
        @testset "PiTimes" begin
            @test p*p === PiExpTimes{2}(p.x^2)
            @test p*p ≈ (p.x*π)^2
            @test p*q === PiExpTimes{2}(p.x*q.x)
            @test q*p === PiExpTimes{2}(p.x*q.x)
            @test p*q ≈ (p.x*q.x)*π^2
            @test p*r === PiExpTimes{3}(p.x*r.x) ≈ (p.x*r.x)*π^3
            @test r*p === PiExpTimes{3}(p.x*r.x) ≈ (p.x*r.x)*π^3
        end
        @testset "Real" begin
            @testset "Int" begin
                @test p*2 === PiTimes(p.x*2)
                @test 2*p === PiTimes(p.x*2)
                @test 2p === PiTimes(p.x*2)
                @test 2r === PiExpTimes{2}(2r.x)

                @test PiExpTimes{0}(3) * 2 === 6
                @test 2 * PiExpTimes{0}(3) === 6
            end
            @testset "Bool" begin
                @test true*p === p
                @test p*true === p
                @test false*p === zero(p)
                @test p*false === zero(p)

                @test PiExpTimes{0}(3) * true === 3
                @test PiExpTimes{0}(3) * false === 0
                @test PiExpTimes{0}(3.0) * true === 3.0
                @test PiExpTimes{0}(3.0) * false === 0.0
                @test PiExpTimes{0}(-3.0) * true === -3.0
                @test PiExpTimes{0}(-3.0) * false === -0.0
            end
            @testset "float" begin
                @test p*1/p === 1.0
                @test r*1/r === 1.0

                @test 2.3*p === PiTimes(2.3*p.x)

                @test PiExpTimes{0}(3.0) * 2 === 6.0
                @test 2 * PiExpTimes{0}(3.0) === 6.0

                @test 2 * PiExpTimes{0}(-3.0) === -6.0
            end
        end
        
        @testset "Complex" begin
            @testset "Complex{Bool}" begin
                @test p * im === PiTimes(0) + PiTimes(p.x)*im 
                @test im* p === PiTimes(0) + PiTimes(p.x)*im
                @test Complex(true,false)*Pi === Pi + im*zero(Pi)
                @test Complex(false,true)*Pi === zero(Pi) + im*Pi
                @test Pi*Complex(false,true) === zero(Pi) + im*Pi
            end
            @testset "Complex{Int}" begin
                @test (1+im)*p === PiTimes(p.x) + PiTimes(p.x)*im
                @test p*(1+im) === PiTimes(p.x) + PiTimes(p.x)*im
            end
        end
    end

    @testset "division" begin
        @testset "PiTimes" begin
            @test p/p === p.x/p.x
            @test p/q === p.x/q.x == 3/4 # works as 1/4 can be stored exactly
            @test q/p === q.x/p.x
        end
        @testset "PiExpTimes" begin
            @test r/r === 1.0
            @test r/p === PiTimes(r.x/p.x)
            @test p/r === PiExpTimes{-1}(p.x/r.x)
        end
        @testset "Real" begin
            @testset "Int" begin
                @test p/2 === PiTimes(p.x/2)
                @test PiTimes(3)/4 === PiTimes(3/4)
            end
            @testset "Bool" begin
                @test p/true === PiTimes(p.x/true)
                @test p/false === PiTimes(Inf)
                @test true/Pi === PiExpTimes{-1}(1.0)
                @test false/Pi === PiExpTimes{-1}(0.0)
            end
        end
        @testset "pi" begin
            @test p/π === p.x
            @test PiTimes(7.3)/π === 7.3
            @test π/PiTimes(1/7.3) ≈ 7.3 # within rounding errors
            @test π/PiTimes(1//7) === 7//1

            @test Pi^2/π === Pi
            @test π/Pi^2 === Pi^-1
        end
        @testset "Complex" begin
            @testset "Complex{Bool}" begin
                @test p/im === Complex(PiTimes(zero(Float64)),PiTimes(-p.x/1))
                @test p/Complex(true,false) === Complex(PiTimes(p.x/1),PiTimes(-zero(Float64)))
                @test im/Pi === im*PiExpTimes{-1}(1.0)
                @test Complex(true,false)/Pi === Complex(true,false)*PiExpTimes{-1}(1.0)
                @test Pi*Pi/im == -1.0Pi*Pi*im
            end
            @testset "Complex{Int}" begin
                @test p/(1+im) === Complex(1.5Pi,-1.5Pi)
                @test Pi/2im === Complex(0.0Pi,-0.5Pi)
                @test (1+im)/Pi === (1+im)*PiExpTimes{-1}(1.0)
            end
            @testset "Complex{PiTimes}" begin
                @testset "Real/Complex{PiExpTimes}" begin
                    @test Pi*Pi/(im*Pi*Pi) === Complex(0.0,-1.0)
                    resim = -PiExpTimes{-1}(1.0)
                    @test Pi/(im*Pi*Pi) === Complex(zero(resim),resim)
                end

                @testset "Complex{PiExpTimes}/Real" begin
                    @testset "Complex{PiExpTimes}/Int" begin
                        @test Pi*Pi*im/1 === Complex(0.0*Pi^2,1.0*Pi^2)
                    end
                    @testset "Complex{PiExpTimes}/PiExpTimes" begin
                        @test (Pi*im)/Pi === 1.0im
                        @test Pi*Pi*im/Pi === 1.0Pi*im
                        @test Pi*Pi*im/(Pi*Pi) === Complex(0.0,1.0)
                    end
                end

                @testset "Complex{PiExpTimes}/Complex" begin
                    @testset "Complex{PiExpTimes}/Complex{Int}" begin
                        z = Pi*(1+2im)/(1+2im)
                        @test real(z) === PiTimes(1.0)
                        @test iszero(imag(z))
                    end
                    @testset "Complex{PiExpTimes}/Complex{PiExpTimes}" begin
                        z = Pi*(1+2im)
                        @test isone(real(z/z))
                        @test iszero(imag(z/z))

                        @test Pi^2*im/(im*Pi^2) === Complex(1.0,0.0)
                        @test Pi^2*im/(im*Pi) === Complex(1.0,0.0)*Pi
                        @test Pi*im/(im*Pi^2) === Complex(1.0,0.0)*Pi^-1
                    end
                end
            end
        end
    end

    @testset "exponentiation" begin
        @testset "Int exponent" begin
            @test Pi^0 === PiExpTimes{0}(1) === 1
            @test Pi^1 === Pi == π
            @test Pi^2 === PiExpTimes{2}(1) == π*π
            @test Pi^-1 === 1/Pi === PiExpTimes{-1}(1.0) ≈ 1/π
            @test Pi^-2 === 1/Pi^2 === PiExpTimes{-2}(1.0) ≈ 1/π^2

            for n=1:10
                @test Pi^-n == 1/Pi^n
                @test float(Pi^-n) === float(1/Pi^n) ≈ 1/π^n
            end

            @test (Pi^2)^0 === 1
        end

        @testset "Float64 exponent" begin
            @test Pi^2.0 === pi^2.0
            @test Pi^-2.0 === pi^-2.0
            @test Pi^0.0 === 1.0
        end

        @testset "Irrational exponent" begin
            @test Pi^Pi === pi^pi
            @test Pi^π === pi^pi
            @test π^Pi === pi^pi
        end

        @testset "reciprocal" begin
            @test Pi * Pi^-1 === 1.0
            @test Pi^-1 * Pi === 1.0
            @test 2Pi * Pi^-1 === 2.0
            @test 2Pi^2 * Pi^-2 === 2.0
        end
    end

    @testset "inv" begin
        @test inv(Pi) === PiExpTimes{-1}(1.0)
        @test inv(Pi^2) === PiExpTimes{-2}(1.0)
        @test inv(PiExpTimes{0,Int}(1)) === 1.0
    end

    @testset "Rational" begin
        @test p//2 === PiTimes(p.x//2)
        @test Pi//2 === PiTimes(1//2)
        @test Pi//Pi === 1//1
        @test 3Pi//4Pi === 3//4
        @test (1//2)Pi//3Pi === 1//6
        @test 2Pi//(3//2)Pi === 4//3
        @test (1//2)Pi//(1//3)Pi === 3//2
        @test (1//2 + 3//2 * im)Pi === (1+3im)*Pi // 2

        @test PiExpTimes{0,Int}(1)//2 === 1//2

        @testset "pi" begin
            @test π//Pi === 1//1
            @test Pi//π === 1//1

            @test π//Pi^2 === (1//Pi)
            @test Pi^2//π === Pi//1
            @test PiExpTimes{0,Int}(1)//π === 1//Pi
        end

        @testset "PiExpTimes // PiExpTimes" begin
            @test Pi^2//Pi === Pi//1
            @test Pi//Pi^2 === 1//Pi
            @test (3Pi^2//2)//(Pi//2) == 3Pi//1
            @test (3Pi//2)//(Pi^2//2) == (3//Pi)
        end
        
        @testset "Real // Complex" begin
            @testset "Complex{Int}" begin
                @test Pi//(2im) === (0//1 - 1//2*im)*Pi
                @test Pi^2//(2im) === (0//1 - 1//2*im)*Pi^2
                @test Pi^-1//(2im) === (0//1 - 1//2*im)*Pi^-1
            end
            @testset "Complex{PiTimes}" begin
                @test 2Pi // (2Pi + 0Pi*im) === 1//1 + 0//1*im
                @test 2Pi^2 // (2Pi^2 + 0Pi^2*im) === 1//1 + 0//1*im
                @test 2Pi^2 // (2Pi + 0Pi*im) === (1//1)*Pi + (0//1)*Pi*im
                @test 2Pi // (2Pi^2 + 0Pi^2*im) === (1//Pi) + (0//Pi)*im
            end
        end

        @testset "Complex // Real" begin
            @test (2//1 + 1//1*im)Pi // 2 === (1//1 + 1//2*im)Pi
            @test (2//1 + 1//1*im)Pi^2 // 2 === (1//1 + 1//2*im)Pi^2
            @test (2//1 + 1//1*im)Pi // Pi === (2//1 + 1//1*im)
            @test (2//1 + 1//1*im)Pi^2 // Pi^2 === (2//1 + 1//1*im)
            @test (2//1 + 1//1*im)Pi^2 // Pi === (2//1 + 1//1*im)*Pi
            @test (2//1 + 1//1*im)Pi // Pi^2 === (2//Pi + (1//Pi)*im)
            @test Complex(π,π)//Pi === Complex(1//1,1//1)
            @test Complex(π,π)//Pi^2 === Complex(1//Pi,1//Pi)
            @test_throws MethodError Complex(π,π)//Pi^-2
        end
        
        @testset "Complex // Complex" begin
            z1 = (1//2 + 3//2 * im)Pi
            z2 = (1//2 + 3//2 * im)Pi^2
            @test z1 // z1 === (1//1 + 0//1 *im)
            @test z2 // z2 === (1//1 + 0//1 *im)
            @test z2 // z1 === (1//1 + 0//1 * im)*Pi
            @test z1 // z2 === (1 + 0*im)//Pi
        end
    end

    @testset "Irrational" begin
        @testset "pi" begin
            @test Pi + π === 2Pi
            @test π + Pi === 2Pi
            @test Pi - π === zero(Pi) == 0
            @test π - Pi === zero(Pi) == 0
            @test π*Pi === PiTimes(Pi)
            @test Pi*π === PiTimes(Pi)
            @test 2Pi*π === PiTimes(2Pi)
            @test π*2Pi === PiTimes(2Pi)
            @test Pi/π === 1 == π/π
            @test π/Pi === 1.0 === π/π
            @test PiTimes(Pi)/π === Pi
            @test Pi*Pi/π === Pi
            @test Pi*π/Pi === PiTimes(one(Float64))
            @test Pi*π/Pi == Pi == pi
            @test Pi^π === π^π
            @test π^Pi === π^π
        end
        @testset "e" begin
            @test Pi + ℯ === π + ℯ
            @test ℯ + Pi === ℯ + π
            @test Pi - ℯ === π - ℯ
            @test ℯ - Pi === ℯ - π
            @test ℯ*Pi === ℯ*π
            @test Pi*ℯ === π*ℯ
            @test Pi/ℯ === π/ℯ
            @test ℯ/Pi === ℯ/π
            @test Pi^ℯ === π^ℯ
            @test ℯ^Pi === ℯ^π
        end
    end
end

@testset "trigonometric functions" begin
    @testset "PiTimes" begin
        @testset "sin and cos" begin
            x = 1.5
            @test sin(PiTimes(x)) == sinpi(x) == -1 ≈ sin(π*x)
            x = 1
            @test cos(PiTimes(x)) == cospi(x) == -1 ≈ cos(π*x)
            
            a = sincos(PiTimes(x))
            @test a[1] == sinpi(x)
            @test a[2] == cospi(x)
        end

        @testset "complex exp" begin
            x = 1.1
            @test cis(PiTimes(x)) == cospi(x) + im*sinpi(x) ≈ cos(π*x) + im*sin(π*x)

            @test exp(im*PiTimes(0)) == cis(PiTimes(0)) == 1
            @test exp(im*PiTimes(1/2)) == cis(PiTimes(1/2)) == im
            @test exp(im*PiTimes(1)) == cis(PiTimes(1))== -1
            @test exp(im*PiTimes(3/2)) == cis(PiTimes(3/2)) == -im

            @test exp(im*Pi/2) == im
            @test exp(im*Pi) == -1
            @test exp(im*3Pi/2) == -im
        end

        @testset "sec and csc" begin
            @test sec(PiTimes(1)) == -1
            @test sec(Pi) == -1
            @test sec(PiTimes(2)) == 1
            @test sec(2Pi) == 1
            @test !isfinite(sec(PiTimes(1/2)))
            @test !isfinite(sec(Pi/2))

            @test csc(PiTimes(1/2)) == 1
            @test csc(Pi/2) == 1
            @test csc(PiTimes(3/2)) == -1
            @test csc(3Pi/2) == -1
            @test !isfinite(csc(PiTimes(1))) 
            @test !isfinite(csc(Pi))
        end

        @testset "tan and cot" begin
            @testset "tan" begin
                @test isinf(tan(Pi/2))
                @test isinf(tan(-Pi/2))
                @test tan(Pi/4) == 1
                @test tan(-Pi/4) == -1
                @test tan(Pi*0) == 0
                @test tan(-Pi*0) == 0
                @test tan(Pi) == 0
                @test tan(-Pi) == 0
                @test tan(2Pi) == 0
                @test tan(-2Pi) == 0
                @test tan(Pi/8) == tan(pi/8)

                @test tan(nextfloat(0.0)*π) == tan(PiTimes(nextfloat(0.0)))
                @test tan(prevfloat(0.0)*π) == tan(PiTimes(prevfloat(0.0)))
            end
            @testset "cot" begin
                @test cot(Pi/2) == 0
                @test cot(-Pi/2) == 0
                @test cot(Pi/4) == 1
                @test cot(-Pi/4) == -1
                @test isinf(cot(Pi*0))
                @test isinf(cot(-Pi*0))
                @test isinf(cot(Pi))
                @test isinf(cot(-Pi))
                @test isinf(cot(2Pi))
                @test isinf(cot(-2Pi))
                @test cot(Pi/8) == cot(pi/8)

                @test cot(nextfloat(0.0)*π) == cot(PiTimes(nextfloat(0.0)))
                @test cot(prevfloat(0.0)*π) == cot(PiTimes(prevfloat(0.0)))
            end
        end

        @testset "sinc" begin
            @test sinc(Pi) === sinc(π)
        end
    end
    @testset "PiExpTimes" begin
        @testset "Pi^2" begin
            @test sin(Pi^2) === sin(π^2)
            @test cos(Pi^2) === cos(π^2)
            @test sincos(Pi^2) === sincos(π^2)
            @test tan(Pi^2) === tan(π^2)
            @test cot(Pi^2) === cot(π^2)
            @test sinc(Pi^2) === sinc(π^2)
            @test sinc(Pi^-2) ≈ sinc(π^-2) # should be equal ideally
            @test sinc(1/Pi^2) ≈ sinc(π^-2) # should be equal ideally
            @test sec(Pi^2) === sec(π^2)
            @test csc(Pi^2) === csc(π^2)
        end
        @testset "Pi^0" begin
            x = 1
            p = PiExpTimes{0,Int}(x)
            @test sin(p) === sin(x)
            @test cos(p) === cos(x)
            @test sincos(p) === sincos(x)
            @test tan(p) === tan(x)
            @test cot(p) === cot(x)
            @test sinc(p) === sinc(x)
            @test sinc(p) === sinc(x)
            @test sec(p) === sec(x)
            @test csc(p) === csc(x)
        end
    end
end

@testset "hyperbolic" begin
    @testset "cosh" begin
        @test cosh(im*PiTimes(1/2)) == 0
    end
    @testset "sinh" begin
        @test sinh(im*PiTimes(-1)) == 0
    end
    @testset "tanh" begin
        @test tanh(im*Pi/4) == im
        @test tanh(im*Pi/2) == im*Inf
        @test tanh(im*Pi/3) == im*tan(Pi/3)
        @test tanh((1+im)*Pi) == tanh((1+im)*π)
        @test tanh(2+im*Pi) == tanh(2+im*π)
    end

    @testset "PiExpTimes" begin
        @testset "Pi^2" begin
            @test sinh(Pi^2) === sinh(π^2)
            @test cosh(Pi^2) === cosh(π^2)
            @test tanh(Pi^2) === tanh(π^2)
        end
        @testset "Pi^0" begin
            x = 1
            p = PiExpTimes{0,Int}(x)
            @test sinh(p) === sinh(x)
            @test cosh(p) === cosh(x)
            @test tanh(p) === tanh(x)
        end
    end
end

@testset "Inf NaN zero check" begin
    @testset "PiTimes" begin
        @test isinf(PiTimes(Inf))
        @test !isfinite(PiTimes(Inf))
        @test isfinite(Pi)
        @test isnan(PiTimes(NaN))
        @test iszero(PiTimes(0))
    end
    @testset "PiExpTimes" begin
        @test isinf(PiExpTimes{2}(Inf))
        @test isinf(PiExpTimes{0}(Inf))
        @test isinf(PiExpTimes{-1}(Inf))
        
        @test !isfinite(PiExpTimes{2}(Inf))
        @test !isfinite(PiExpTimes{0}(Inf))
        @test !isfinite(PiExpTimes{-1}(Inf))
        
        @test isnan(PiExpTimes{-1}(NaN))
        @test isnan(PiExpTimes{0}(NaN))

        @test iszero(PiExpTimes{2}(0))
        @test iszero(PiExpTimes{0}(0))
    end
end

@testset "show" begin
    io = IOBuffer()

    @testset "Int" begin
        show(io,Pi)
        @test String(take!(io)) == "Pi"
        show(io,2Pi)
        @test String(take!(io)) == "2Pi"
        show(io,0*Pi)
        @test String(take!(io)) == "0"
    end

    @testset "Rational" begin
        show(io,(1//1)*Pi)
        @test String(take!(io)) == "(1//1)Pi"
        show(io,(2//3)*Pi)
        @test String(take!(io)) == "(2//3)Pi"
        show(io,(2//3)*Pi*Pi)
        @test String(take!(io)) == "(2//3)Pi^2"
    end

    @testset "float" begin
        show(io,1.0Pi)
        @test String(take!(io)) == "Pi"
        show(io,2.0Pi)
        @test String(take!(io)) == "2.0*Pi"
        show(io,0.0Pi)
        @test String(take!(io)) == "0.0"
        show(io,-0.0Pi)
        @test String(take!(io)) == "-0.0"

        @testset "inf nan" begin
            show(io,Inf*Pi)
            @test String(take!(io)) == "Inf"
            show(io,-Inf*Pi)
            @test String(take!(io)) == "-Inf"
            show(io,NaN*Pi)
            @test String(take!(io)) == "NaN"
        end
    end
    
    @testset "nested" begin
        show(io,Pi*Pi)
        @test String(take!(io)) == "Pi^2"
        show(io,Pi*Pi*Pi)
        @test String(take!(io)) == "Pi^3"
    end

    @testset "complex" begin
        show(io,im*Pi)
        @test String(take!(io)) == "0 + Pi*im"

        @testset "nested" begin
            show(io,im*Pi*Pi)
            @test String(take!(io)) == "0 + Pi^2*im"
        end

        @testset "float" begin
            show(io,im*1.2*Pi)
            @test String(take!(io)) == "0.0 + 1.2*Pi*im"
            show(io,PiTimes(-0.0)*im)
            @test String(take!(io)) == "-0.0 - 0.0*im"
        end

        @testset "Rational" begin
            show(io,Pi + im*(2//3)Pi)
            @test String(take!(io)) == "(1//1)Pi + (2//3)Pi*im"
            show(io,Pi*Pi*(2//3)*im)
            @test String(take!(io)) == "0//1 + (2//3)Pi^2*im"
        end
    end    
end