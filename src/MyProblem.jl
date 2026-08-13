"""
--------------------------------------------------------------------------------
inip — Problem initialization
--------------------------------------------------------------------------------

Initializes the dimensions, bounds, initial point and configuration flags
for a selected test problem.

The problem is selected by its string identifier `PROBLEM` and the initial
point is generated using a pseudo-random seed.

--------------------------------------------------------------------------------
Inputs:

    PROBLEM :: String   → Name of the test problem
    SEED    :: Int      → Random seed for reproducibility

--------------------------------------------------------------------------------
Outputs:

    n         :: Int        → Number of variables
    m         :: Int        → Number of objective functions
    x         :: Vector{T} → Initial point
    l, u      :: Vector{T} → Lower and upper bounds
    strconvex:: Vector{Bool} → Convexity flags of objectives
    scaleF   :: Bool       → Enable/disable objective scaling
    checkder :: Bool       → Enable/disable derivative checking

--------------------------------------------------------------------------------
"""
function inip(PROBLEM::String; rng::AbstractRNG = Random.default_rng())

    if PROBLEM == "F1"
        # Number of variables and number of objective functions
        n, m = 10, 2

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l = fill(ZERO, n)
        u = fill(ONE , n)
        l[1] = T(1.0e-6)

        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        strconvex = Bool[false, false]     # nonconvex / not convex in general
        scaleF, checkder = true, false
    
    elseif PROBLEM == "F2"
        # Number of variables and number of objective functions
        n, m = 30, 2

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l[1] = T(1.0e-6)
        u[1] = ONE

        for i in 2:n
            l[i] = T(-1)
            u[i] = T(1)
        end

        # Random initial point
        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        # Convexity information
        strconvex = Bool[false, false]

        # Objective scaling and derivative checking
        scaleF, checkder = true, false

    elseif PROBLEM == "F3"
        # Number of variables and number of objective functions
        n, m = 30, 2

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l[1] = T(1.0e-6)
        u[1] = ONE

        for i in 2:n
            l[i] = T(-1)
            u[i] = T(1)
        end

        # Random initial point
        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        # Objective scaling and derivative checking
        strconvex = Bool[false, false]
        scaleF, checkder = true, false

    elseif PROBLEM == "F4"
        # Number of variables and number of objective functions
        n, m = 30, 2

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l[1] = T(1.0e-6)
        u[1] = ONE

        for i in 2:n
            l[i] = T(-1)
            u[i] = T(1)
        end

        # Random initial point
        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        # Objective scaling and derivative checking
        strconvex = Bool[false, false]
        scaleF, checkder = true, false

    elseif PROBLEM == "F5"
        # Number of variables and number of objective functions
        n, m = 30, 2

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l[1] = T(1.0e-6)
        u[1] = ONE

        for i in 2:n
            l[i] = T(-1)
            u[i] = T(1)
        end

        # Random initial point
        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        # Convexity information
        strconvex = Bool[false, false]

        # Objective scaling and derivative checking
        scaleF, checkder = true, false

    elseif PROBLEM == "F6"
        # Number of variables and number of objective functions
        n, m = 10, 3

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l[1] = ZERO
        u[1] = ONE
        l[2] = ZERO
        u[2] = ONE

        for i in 3:n
            l[i] = T(-2)
            u[i] = T( 2)
        end

        # Random initial point
        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        # Convexity information
        strconvex = Bool[false, false, false]

        # Objective scaling and derivative checking
        scaleF, checkder = true, false

    elseif PROBLEM == "F7"
        # Number of variables and number of objective functions
        n, m = 10, 2

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l = fill(ZERO, n)
        u = fill(ONE , n)
        l[1] = T(1.0e-6)

        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        strconvex = Bool[false, false]     # nonconvex / not convex in general
        scaleF, checkder = true, false

    elseif PROBLEM == "F8"
        # Number of variables and number of objective functions
        n, m = 30, 2

        # Lower and upper bounds
        l = fill(ZERO, n)
        u = fill(ONE,  n)
        l[1] = T(1.0e-6)

        # Random initial point
        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        # Convexity information
        strconvex = Bool[false, false]

        # Objective scaling and derivative checking
        scaleF, checkder = true, false
    
    elseif PROBLEM == "F9"
        # Number of variables and number of objective functions
        n, m = 30, 2

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l[1] = ZERO
        u[1] = ONE

        for i in 2:n
            l[i] = T(-1)
            u[i] = T(1)
        end

        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        strconvex = Bool[false, false]     # nonconvex / not convex in general
        scaleF, checkder = true, false

    

    
    
    





    
    elseif PROBLEM == "CEC04"
        # Number of variables and number of objective functions
        n, m = 30, 2

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l[1] = ZERO
        u[1] = ONE

        for i in 2:n
            l[i] = T(-2)
            u[i] = T( 2)
        end

        # Random initial point
        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        # Convexity information
        strconvex = Bool[false, false]

        # Objective scaling and derivative checking
        scaleF, checkder = true, false

    elseif PROBLEM == "CEC05"
        # Number of variables and number of objective functions
        n, m = 30, 2

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l[1] = ZERO
        u[1] = ONE

        for i in 2:n
            l[i] = T(-1)
            u[i] = T( 1)
        end

        # Random initial point
        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        # Convexity information
        strconvex = Bool[false, false]

        # Objective scaling and derivative checking
        scaleF, checkder = true, false

    elseif PROBLEM == "CEC06"
        # Number of variables and number of objective functions
        n, m = 30, 2

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l[1] = ZERO
        u[1] = ONE
        for i in 2:n
            l[i] = T(-1)
            u[i] = T( 1)
        end

        # Random initial point
        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        # Convexity information
        strconvex = Bool[false, false]

        # Objective scaling and derivative checking
        scaleF, checkder = true, false

    elseif PROBLEM == "CEC07"
        # Number of variables and number of objective functions
        n, m = 30, 2

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l[1] = ZERO
        u[1] = ONE
        for i in 2:n
            l[i] = T(-1)
            u[i] = T( 1)
        end

        # Random initial point
        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        # Convexity information
        strconvex = Bool[false, false]

        # Objective scaling and derivative checking
        scaleF, checkder = true, false

    

    elseif PROBLEM == "CEC09"
        # Number of variables and number of objective functions
        n, m = 30, 3

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l[1] = ZERO
        u[1] = ONE

        # l[1] = T(1/4)
        # u[1] = T(3/4)


        l[2] = ZERO
        u[2] = ONE

        for i in 3:n
            l[i] = T(-2)
            u[i] = T( 2)
        end

        # Random initial point
        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        # Convexity information
        strconvex = Bool[false, false, false]

        # Objective scaling and derivative checking
        scaleF, checkder = true, false

    elseif PROBLEM == "CEC10"
        # Number of variables and number of objective functions
        n, m = 30, 3

        # Lower and upper bounds
        l = Vector{T}(undef, n)
        u = Vector{T}(undef, n)

        l[1] = ZERO
        u[1] = ONE

        l[2] = ZERO
        u[2] = ONE

        for i in 3:n
            l[i] = T(-2)
            u[i] = T( 2)
        end

        # Random initial point
        x = [l[i] + (u[i] - l[i]) * rand(rng, T) for i in 1:n]

        # Convexity information
        strconvex = Bool[false, false, false]

        # Objective scaling and derivative checking
        scaleF, checkder = true, false











    

    elseif PROBLEM == "AP1"
        n, m = 2, 3
        l = fill(T(-1e1), n)
        u = fill(T( 1e1), n)
        x = [l[i] + (u[i] - l[i]) * rand(rng,T) for i in 1:n]
        strconvex = Bool[false, true, true]
        scaleF, checkder = true, false

    elseif PROBLEM == "AP2"
        n, m = 1, 2
        l = fill(T(-1e2), n)
        u = fill(T( 1e2), n)
        x = [l[i] + (u[i] - l[i]) * rand(rng,T) for i in 1:n]
        strconvex = Bool[true, true]
        scaleF, checkder = true, false

    elseif PROBLEM == "AP3"
        n, m = 2, 2
        l = fill(T(-1e2), n)
        u = fill(T( 1e2), n)
        x = [l[i] + (u[i] - l[i]) * rand(rng,T) for i in 1:n]
        strconvex = Bool[false, false]
        scaleF, checkder = true, false

    elseif PROBLEM == "AP4"
        n, m = 3, 3
        l = fill(T(-1e1), n)
        u = fill(T( 1e1), n)
        x = [l[i] + (u[i] - l[i]) * rand(rng,T) for i in 1:n]
        strconvex = Bool[false, true, true]
        scaleF, checkder = true, false

    elseif PROBLEM == "DD1"
        # Das & Dennis (1998)
        n, m = 5, 2
        l = fill(T(-20.0), n)
        u = fill(T( 20.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        x .= 10 * rand(rng,T) .* x ./ norm(x)
        strconvex = Bool[true, false]
        scaleF, checkder = true, false

    elseif PROBLEM == "DGO1"
        # Review of Multiobjective Test PROBLEMs
        n, m = 1, 2
        l = T[-10.0]
        u = T[13.0]
        x = [l[1] + (u[1]-l[1])*rand(rng,T)]
        strconvex = Bool[false, false]
        scaleF, checkder = true, false

    elseif PROBLEM == "DGO2"
        n, m = 1, 2
        l = T[-9.0]
        u = T[9.0]
        x = [l[1] + (u[1]-l[1])*rand(rng,T)]
        strconvex = Bool[true, true]
        scaleF, checkder = true, false

    elseif PROBLEM == "FA1"
        # Review of Multiobjective Test PROBLEMs (FA1)
        n, m = 3, 3
        l = fill(T(0.0), n)
        u = fill(T(1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "Far1"
        # Review of Multiobjective Test PROBLEMs (Far1)
        n, m = 2, 2
        l = fill(T(-1.0), n)
        u = fill(T( 1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "FDS"
        # Newton’s Method for Multiobjective Optimization
        n, m = 200, 3
        l = fill(T(-2.0), n)
        u = fill(T( 2.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = trues(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "FF1"
        # Fonseca & Fleming
        n, m = 2, 2
        l = fill(T(-1.0), n)
        u = fill(T( 1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "Hil1"
        # Generalized Homotopy Approach to Multiobjective Optimization
        n, m = 2, 2
        l = fill(T(0.0), n)
        u = fill(T(1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "IKK1"
        # Review of Multiobjective Test PROBLEMs
        n, m = 2, 3
        l = fill(T(-50.0), n)
        u = fill(T( 50.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "IM1"
        # Review of Multiobjective Test PROBLEMs
        n, m = 2, 2
        l = T[1.0, 1.0]
        u = T[4.0, 2.0]
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "JOS1"
        # Dynamic Weighted Aggregation for Evolutionary Multiobjective Optimization
        n, m = 100, 2
        l = fill(T(-100.0), n)
        u = fill(T( 100.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = trues(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "JOS4"
        # Newton’s Method for Multiobjective Optimization
        n, m = 100, 2
        l = fill(T(1e-2), n)
        u = fill(T(1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "KW2"
        # Kim & de Weck (Adaptive weighted-sum method)
        n, m = 2, 2
        l = fill(T(-3.0), n)
        u = fill(T( 3.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "LE1"
        # Review of Multiobjective Test PROBLEMs (LE1)
        n, m = 2, 2
        l = fill(T(-5.0), n)
        u = fill(T(10.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "Lov1"
        # Singular Continuation (PROBLEM 1)
        n, m = 2, 2
        l = fill(T(-10.0), n)
        u = fill(T( 10.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = trues(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "Lov2"
        # Singular Continuation (PROBLEM 2)
        n, m = 2, 2
        l = fill(T(-0.75), n)
        u = fill(T( 0.75), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "Lov3"
        # Singular Continuation (PROBLEM 3)
        n, m = 2, 2
        l = fill(T(-20.0), n)
        u = fill(T( 20.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = Bool[true, false]
        scaleF, checkder = true, false

    elseif PROBLEM == "Lov4"
        # Singular Continuation (PROBLEM 4)
        n, m = 2, 2
        l = fill(T(-20.0), n)
        u = fill(T( 20.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = Bool[false, true]
        scaleF, checkder = true, false

    elseif PROBLEM == "Lov5"
        # Singular Continuation (PROBLEM 5)
        n, m = 3, 2
        l = fill(T(-2.0), n)
        u = fill(T( 2.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "Lov6"
        # Singular Continuation (PROBLEM 6)
        n, m = 6, 2
        l = T[0.1; fill(-0.16, 5)...]
        u = T[0.425; fill( 0.16, 5)...]
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "LTDZ"
        # Combining convergence and diversity
        n, m = 3, 3
        l = fill(T(0.0), n)
        u = fill(T(1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MGH9"
        # Gaussian test PROBLEM (More et al., 1981)
        n, m = 3, 15
        l = fill(T(-2.0), n)
        u = fill(T( 2.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MGH16"
        # Brown and Dennis test PROBLEM
        n, m = 4, 5
        l = T[-25.0, -5.0, -5.0, -1.0]
        u = T[ 25.0,  5.0,  5.0,  1.0]
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MGH26"
        # Trigonometric PROBLEM
        n = 4; m = n
        l = fill(T(-1.0), n)
        u = fill(T( 1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MGH33"
        # Linear function (rank 1)
        n = 10; m = n
        l = fill(T(-1.0), n)
        u = fill(T( 1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MHHM2"
        # Review of Multiobjective Test PROBLEMs
        n, m = 2, 3
        l = fill(T(0.0), n)
        u = fill(T(1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = trues(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MLF1"
        # Review of Multiobjective Test PROBLEMs
        n, m = 1, 2
        l = T[0.0]; u = T[20.0]
        x = [l[1] + (u[1]-l[1])*rand(rng,T)]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MLF2"
        # Review of Multiobjective Test PROBLEMs
        n, m = 2, 2
        l = fill(T(-100.0), n)
        u = fill(T( 100.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MMR1"
        # Box-constrained multi-objective optimization (modified)
        n, m = 2, 2
        l = T[0.1, 0.0]
        u = T[1.0, 1.0]
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MMR3"
        n, m = 2, 2
        l = fill(T(-1.0), n)
        u = fill(T( 1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MMR4"
        n, m = 3, 2
        l = fill(T(0.0), n)
        u = fill(T(4.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MOP2"
        n, m = 2, 2
        l = fill(T(-1.0), n)
        u = fill(T( 1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MOP3"
        n, m = 2, 2
        l = fill(T(-π), n)
        u = fill(T( π), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = Bool[false, true]
        scaleF, checkder = true, false

    elseif PROBLEM == "MOP5"
        n, m = 2, 3
        l = fill(T(-1.0), n)
        u = fill(T( 1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MOP6"
        n, m = 2, 2
        l = fill(T(0.0), n)
        u = fill(T(1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "MOP7"
        n, m = 2, 3
        l = fill(T(-400.0), n)
        u = fill(T( 400.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = trues(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "PNR"
        n, m = 2, 2
        l = fill(T(-2.0), n)
        u = fill(T( 2.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = Bool[false, true]
        scaleF, checkder = true, false

    elseif PROBLEM == "QV1"
        n, m = 100, 2
        l = fill(T(-5.0), n)
        u = fill(T( 5.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "SD"
        n, m = 4, 2
        l = T[1.0, √2, √2, 1.0]
        u = T[3.0, 3.0, 3.0, 3.0]
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = Bool[false, true]
        scaleF, checkder = true, false

    elseif PROBLEM == "SLCDT1"
        n, m = 2, 2
        l = fill(T(-1.5), n)
        u = fill(T( 1.5), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "SLCDT2"
        n, m = 100, 3
        l = fill(T(-1.0), n)
        u = fill(T( 1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "SP1"
        n, m = 2, 2
        l = fill(T(-100.0), n)
        u = fill(T( 100.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = trues(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "SSFYY2"
        n, m = 1, 2
        l = T[-100.0]
        u = T[ 100.0]
        x = [l[1] + (u[1]-l[1])*rand(rng,T)]
        strconvex = Bool[false, true]
        scaleF, checkder = true, false

    elseif PROBLEM == "SK1"
        n, m = 1, 2
        l = T[-100.0]
        u = T[ 100.0]
        x = [l[1] + (u[1]-l[1])*rand(rng,T)]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "SK2"
        n, m = 4, 2
        l = fill(T(-10.0), n)
        u = fill(T( 10.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = Bool[true, false]
        scaleF, checkder = true, false

    elseif PROBLEM == "TKLY1"
        n, m = 4, 2
        l = T[0.1, 0.0, 0.0, 0.0]
        u = T[1.0, 1.0, 1.0, 1.0]
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "Toi4"
        n, m = 4, 2
        l = fill(T(-2.0), n)
        u = fill(T( 5.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "Toi8"
        n = 3; m = n
        l = fill(T(-1.0), n)
        u = fill(T( 1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "Toi9"
        n = 4; m = n
        l = fill(T(-1.0), n)
        u = fill(T( 1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "Toi10"
        n = 4; m = n - 1
        l = fill(T(-2.0), n)
        u = fill(T( 2.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "VU1"
        n, m = 2, 2
        l = fill(T(-3.0), n)
        u = fill(T( 3.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = Bool[false, true]
        scaleF, checkder = true, false

    elseif PROBLEM == "VU2"
        n, m = 2, 2
        l = fill(T(-3.0), n)
        u = fill(T( 3.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = Bool[false, true]
        scaleF, checkder = true, false

    elseif PROBLEM == "ZDT1"
        n, m = 30, 2
        l = fill(T(1e-2), n)
        u = fill(T(1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "ZDT2"
        n, m = 30, 2
        l = fill(T(0.0), n)
        u = fill(T(1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "ZDT3"
        n, m = 10, 2
        l = fill(T(1e-2), n)
        u = fill(T(1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "ZDT4"
        n, m = 10, 2
        l = [T(1e-2); fill(T(-5.0), n-1)...]
        u = [1.0; fill(T(5.0), n-1)...]
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "ZDT6"
        n, m = 10, 2
        l = fill(T(0.0), n)
        u = fill(T(1.0), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = falses(m)
        scaleF, checkder = true, false

    elseif PROBLEM == "ZLT1"
        n, m = 100, 5
        l = fill(T(-1e3), n)
        u = fill(T( 1e3), n)
        x = [l[i] + (u[i]-l[i])*rand(rng,T) for i in 1:n]
        strconvex = trues(m)
        scaleF, checkder = true, false
    else
        error("Unknown problem : $PROBLEM")
    end

    return n, m, x, l, u, strconvex, scaleF, checkder
end

# ======================================================================
# Objective function f_i(x)
# ======================================================================
"""
--------------------------------------------------------------------------------
evalf — Objective function evaluation
--------------------------------------------------------------------------------

Evaluates the objective function f_ind(x) for the currently selected problem
stored in the global variable `PROBLEM`.

--------------------------------------------------------------------------------
Inputs:

    ind :: Int        → Objective function index
    x   :: Vector{T} → Current point
    n   :: Int        → Number of variables

--------------------------------------------------------------------------------
Output:

    f :: T  → Objective function value f_ind(x)

--------------------------------------------------------------------------------
"""
function evalf(ind::Int, x::Vector{T}, n::Int) where {T<:AbstractFloat}

    f = ZERO

    if PROBLEM == "F1"
        x1 = x[1]
        J1 = 0
        J2 = 0
        sum1 = ZERO
        sum2 = ZERO

        # Precompute the sums and cardinalities of J1 and J2
        for j in 2:n
            a = T(0.5) * (ONE + T(3) * T(j - 2) / T(n - 2))   # exponent a_j
            y = x[j] - x1^a

            if isodd(j)
                J1 += 1
                sum1 += y^2
            else
                J2 += 1
                sum2 += y^2
            end
        end

        if ind == 1
            f = x1 + (T(2) / T(J1)) * sum1

        elseif ind == 2
            f = ONE - sqrt(x1) + (T(2) / T(J2)) * sum2
        end

    elseif PROBLEM == "F2"
        x1 = x[1]
        J1 = 0
        J2 = 0
        sum1 = ZERO
        sum2 = ZERO

        for j in 2:n
            θ = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
            y = x[j] - sin(θ)

            if isodd(j)
                J1 += 1
                sum1 += y^2
            else
                J2 += 1
                sum2 += y^2
            end
        end

        if ind == 1
            f = x1 + (2 / T(J1)) * sum1

        elseif ind == 2
            f = 1 - sqrt(x1) + (2 / T(J2)) * sum2
        end

    elseif PROBLEM == "F3"
        x1 = x[1]
        J1 = 0
        J2 = 0
        sum1 = ZERO
        sum2 = ZERO

        for j in 2:n
            θ = T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)

            if isodd(j)
                y = x[j] - T(0.8) * x1 * cos(θ)
                J1 += 1
                sum1 += y^2
            else
                y = x[j] - T(0.8) * x1 * sin(θ)
                J2 += 1
                sum2 += y^2
            end
        end

        if ind == 1
            f = x1 + (T(2) / T(J1)) * sum1

        elseif ind == 2
            f = ONE - sqrt(x1) + (T(2) / T(J2)) * sum2
        end

    elseif PROBLEM == "F4"
        x1 = x[1]
        J1 = 0
        J2 = 0
        sum1 = ZERO
        sum2 = ZERO

        for j in 2:n
            θ1 = (T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)) / T(3)
            θ2 =  T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)

            if isodd(j)
                y = x[j] - T(0.8) * x1 * cos(θ1)
                J1 += 1
                sum1 += y^2
            else
                y = x[j] - T(0.8) * x1 * sin(θ2)
                J2 += 1
                sum2 += y^2
            end
        end

        if ind == 1
            f = x1 + (T(2) / T(J1)) * sum1

        elseif ind == 2
            f = ONE - sqrt(x1) + (T(2) / T(J2)) * sum2
        end

    elseif PROBLEM == "F5"

        x1 = x[1]
        J1 = 0
        J2 = 0
        sum1 = ZERO
        sum2 = ZERO

        for j in 2:n
            θ1 = 24*T(pi)*x1 + 4*T(j)*T(pi)/T(n)
            θ2 =  6*T(pi)*x1 +     T(j)*T(pi)/T(n)

            A = 0.3*x1^2 * cos(θ1) + 0.6*x1

            if isodd(j)
                y = x[j] - A * cos(θ2)
                J1 += 1
                sum1 += y^2
            else
                y = x[j] - A * sin(θ2)
                J2 += 1
                sum2 += y^2
            end
        end

        if ind == 1
            f = x1 + (2 / T(J1)) * sum1
        elseif ind == 2
            f = 1 - sqrt(x1) + (2 / T(J2)) * sum2
        end

    elseif PROBLEM == "F6"

        x1 = x[1]
        x2 = x[2]

        c1 = cos(T(pi)/T(2) * x1)
        s1 = sin(T(pi)/T(2) * x1)
        c2 = cos(T(pi)/T(2) * x2)
        s2 = sin(T(pi)/T(2) * x2)

        J1 = 0
        J2 = 0
        J3 = 0

        sum1 = ZERO
        sum2 = ZERO
        sum3 = ZERO

        for j in 3:n
            θ = T(2)*T(pi)*x1 + T(j)*T(pi)/T(n)

            # Correct definition of y_j for F6 (UF8)
            y = x[j] - T(2)*x2 * sin(θ)

            r = mod(j-1, 3)

            if r == 0
                J1 += 1
                sum1 += y^2
            elseif r == 1
                J2 += 1
                sum2 += y^2
            else
                J3 += 1
                sum3 += y^2
            end
        end

        if ind == 1
            f = c1*c2 + (T(2) / T(J1)) * sum1
        elseif ind == 2
            f = c1*s2 + (T(2) / T(J2)) * sum2
        elseif ind == 3
            f = s1 + (T(2) / T(J3)) * sum3
        end

    elseif PROBLEM == "F7"
        x1 = x[1]
        J1 = 0
        J2 = 0
        sum1 = ZERO
        sum2 = ZERO

        for j in 2:n
            a  = T(0.5) * (ONE + T(3) * T(j - 2) / T(n - 2))
            y  = x[j] - x1^a
            φ  = T(4) * y^2 - cos(T(8) * T(pi) * y) + ONE

            if isodd(j)
                J1 += 1
                sum1 += φ
            else
                J2 += 1
                sum2 += φ
            end
        end

        if ind == 1
            f = x1 + (T(2) / T(J1)) * sum1

        elseif ind == 2
            f = ONE - sqrt(x1) + (T(2) / T(J2)) * sum2
        end

    elseif PROBLEM == "F8"

        x1 = x[1]

        # J1: odd indices 2..n, J2: even indices 2..n
        J1 = 0
        J2 = 0

        S1 = ZERO
        S2 = ZERO
        P1 = ONE
        P2 = ONE

        for j in 2:n
            # exponent alpha_j = 0.5 * (1 + 3*(j-2)/(n-2))
            α = T(0.5) * (ONE + T(3) * (T(j-2) / T(n-2)))

            x1α = x1^α
            y   = x[j] - x1α

            φ = 20*T(pi) * y / sqrt(T(j))
            cφ = cos(φ)

            if isodd(j)
                J1 += 1
                S1 += y^2
                P1 *= cφ
            else
                J2 += 1
                S2 += y^2
                P2 *= cφ
            end
        end

        if ind == 1
            f = x1 + (2 / T(J1)) * (4*S1 - 2*P1 + 2)
        elseif ind == 2
            f = ONE - sqrt(x1) + (2 / T(J2)) * (4*S2 - 2*P2 + 2)
        end
    
    elseif PROBLEM == "F9"
        x1 = x[1]
        J1 = 0
        J2 = 0
        sum1 = ZERO
        sum2 = ZERO

        for j in 2:n
            θ = T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)
            y = x[j] - sin(θ)

            if isodd(j)
                J1 += 1
                sum1 += y^2
            else
                J2 += 1
                sum2 += y^2
            end
        end

        if ind == 1
            f = x1 + (T(2) / T(J1)) * sum1

        elseif ind == 2
            f = ONE - x1^2 + (T(2) / T(J2)) * sum2
        end

    elseif PROBLEM == "CEC04"

        x1 = x[1]

        J1 = 0
        J2 = 0
        sum1 = ZERO
        sum2 = ZERO

        for j in 2:n
            θ = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
            y = x[j] - sin(θ)

            a  = abs(y)
            e2 = exp(T(2)*a)
            h  = a / (ONE + e2)   # h(t) = |t| / (1 + e^{2|t|})

            if isodd(j)
                J1 += 1
                sum1 += h
            else
                J2 += 1
                sum2 += h
            end
        end

        if ind == 1
            f = x1 + (T(2) / T(J1)) * sum1
        elseif ind == 2
            f = ONE - x1^2 + (T(2) / T(J2)) * sum2
        end

    elseif PROBLEM == "CEC05"

        x1 = x[1]

        # Parameters of the central term
        N   = T(10)
        eps = T(0.1)
        A   = inv(T(2)*N) + eps          # (1/(2N) + eps)

        # Central term (same in f1 and f2)
        s   = sin(T(2)*N*T(pi)*x1)
        cterm = A * abs(s)

        J1 = 0
        J2 = 0
        sum1 = ZERO
        sum2 = ZERO

        for j in 2:n
            θ = 6*T(pi)*x1 + T(j)*T(pi)/T(n)

            y = x[j] - sin(θ)

            # h(y) = 2 y^2 - cos(4π y) + 1
            h = T(2)*y^2 - cos(T(4)*T(pi)*y) + ONE

            if isodd(j)
                J1 += 1
                sum1 += h
            else
                J2 += 1
                sum2 += h
            end
        end

        if ind == 1
            f = x1 + cterm + (T(2) / T(J1)) * sum1
        elseif ind == 2
            f = ONE - x1 + cterm + (T(2) / T(J2)) * sum2
        end

    elseif PROBLEM == "CEC06"

        x1  = x[1]
        N   = T(2)
        eps = T(0.1)

        # Central "jump" term: max{0, 2(1/(2N)+eps) * sin(2Nπx1)}
        A     = T(2) * (inv(T(2)*N) + eps)
        s2N   = sin(T(2)*N*T(pi)*x1)
        inner = A * s2N
        cterm = max(ZERO, inner)

        J1 = 0
        J2 = 0
        sum1_y2 = ZERO
        sum2_y2 = ZERO
        P1 = ONE
        P2 = ONE

        for j in 2:n
            θ = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
            y = x[j] - sin(θ)
            β = T(20)*T(pi) / sqrt(T(j))

            if isodd(j)
                J1 += 1
                sum1_y2 += y^2
                P1 *= cos(β * y)
            else
                J2 += 1
                sum2_y2 += y^2
                P2 *= cos(β * y)
            end
        end

        if ind == 1
            G1 = T(4)*sum1_y2 - T(2)*P1 + T(2)
            f  = x1 + cterm + (T(2) / T(J1)) * G1
        elseif ind == 2
            G2 = T(4)*sum2_y2 - T(2)*P2 + T(2)
            f  = ONE - x1 + cterm + (T(2) / T(J2)) * G2
        end

    elseif PROBLEM == "CEC07"

        x1 = x[1]

        x1p = x1^(T(1)/T(5))   # x1^(1/5)

        # Count indices in J1 and J2
        J1 = 0
        J2 = 0
        for j in 2:n
            isodd(j) ? (J1 += 1) : (J2 += 1)
        end

        sum1 = ZERO
        sum2 = ZERO

        for j in 2:n
            θ = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
            y = x[j] - sin(θ)

            if isodd(j)
                sum1 += y^2
            else
                sum2 += y^2
            end
        end

        if ind == 1
            f = x1p + (T(2) / T(J1)) * sum1
        elseif ind == 2
            f = ONE - x1p + (T(2) / T(J2)) * sum2
        end

    elseif PROBLEM == "CEC09"

        x1 = x[1]
        x2 = x[2]

        eps = T(0.1)

        g0 = (ONE + eps) * (ONE - T(4)*(T(2)*x1 - ONE)^2)
        g  = max(ZERO, g0)

        J1 = 0
        J2 = 0
        J3 = 0

        sum1 = ZERO
        sum2 = ZERO
        sum3 = ZERO

        for j in 3:n
            θ = T(2)*T(pi)*x1 + T(j)*T(pi)/T(n)
            y = x[j] - T(2)*x2*sin(θ)

            r = mod(j-1, 3)

            if r == 0
                J1 += 1
                sum1 += y^2
            elseif r == 1
                J2 += 1
                sum2 += y^2
            else
                J3 += 1
                sum3 += y^2
            end
        end

        if ind == 1
            f = T(0.5)*(g + T(2)*x1)*x2 + (T(2)/T(J1))*sum1
        elseif ind == 2
            f = T(0.5)*(g - T(2)*x1 + T(2))*x2 + (T(2)/T(J2))*sum2
        elseif ind == 3
            f = ONE - x2 + (T(2)/T(J3))*sum3
        end

    elseif PROBLEM == "CEC10"

        x1 = x[1]
        x2 = x[2]

        # Trigonometric terms of the front
        c1 = cos(T(pi)/T(2) * x1)
        s1 = sin(T(pi)/T(2) * x1)
        c2 = cos(T(pi)/T(2) * x2)
        s2 = sin(T(pi)/T(2) * x2)

        J1 = 0
        J2 = 0
        J3 = 0

        sum1 = ZERO
        sum2 = ZERO
        sum3 = ZERO

        for j in 3:n
            θ  = T(2)*T(pi)*x1 + T(j)*T(pi)/T(n)
            sθ = sin(θ)

            # y_j = x_j - 2 x2 sin(2π x1 + jπ/n)
            y = x[j] - T(2)*x2*sθ

            # h(y) = 4 y^2 - cos(8π y) + 1
            h = T(4)*y^2 - cos(T(8)*T(pi)*y) + ONE

            r = mod(j-1, 3)

            if r == 0
                J1 += 1
                sum1 += h
            elseif r == 1
                J2 += 1
                sum2 += h
            else
                J3 += 1
                sum3 += h
            end
        end

        if ind == 1
            f = c1*c2 + (T(2) / T(J1)) * sum1
        elseif ind == 2
            f = c1*s2 + (T(2) / T(J2)) * sum2
        elseif ind == 3
            f = s1     + (T(2) / T(J3)) * sum3
        end







    
    




    elseif PROBLEM == "AP1"
        if ind == 1
            f = 0.25T((x[1]-1)^4 + 2*(x[2]-2)^4)
        elseif ind == 2
            f = exp((x[1]+x[2])/2) + x[1]^2 + x[2]^2
        elseif ind == 3
            f = (1/6) * (exp(-x[1]) + 2*exp(-x[2]))
        end

    elseif PROBLEM == "AP2"
        f = ind == 1 ? x[1]^2 - 4 : (x[1]-1)^2

    elseif PROBLEM == "AP3"
        f = ind == 1 ? 0.25*((x[1]-1)^4 + 2*(x[2]-2)^4) :
                       (x[2]-x[1]^2)^2 + (1-x[1])^2

    elseif PROBLEM == "AP4"
        if ind == 1
            f = (1/9)*((x[1]-1)^4 + 2*(x[2]-2)^4 + 3*(x[3]-3)^4)
        elseif ind == 2
            f = exp((x[1]+x[2]+x[3])/3) + x[1]^2 + x[2]^2 + x[3]^2
        elseif ind == 3
            f = (1/12)*(3*exp(-x[1]) + 4*exp(-x[2]) + 3*exp(-x[3]))
        end

    elseif PROBLEM == "DD1"
        if ind == 1
            f = sum(x .^ 2)
        elseif ind == 2
            f = 3.0 * x[1] + 2.0 * x[2] - x[3] / 3.0 + 1e-2 * (x[4] - x[5])^3
        end

    elseif PROBLEM == "DGO1"
        if ind == 1
            f = sin(x[1])
        elseif ind == 2
            f = sin(x[1] + 0.7)
        end

    elseif PROBLEM == "DGO2"
        if ind == 1
            f = x[1]^2
        elseif ind == 2
            f = 9.0 - sqrt(81.0 - x[1]^2)
        end

    elseif PROBLEM == "FA1"
        faux = (1 - exp(-4 * x[1])) / (1 - exp(-4))
        if ind == 1
            f = faux
        elseif ind == 2
            f = (x[2] + 1) * (1 - (faux / (x[2] + 1))^0.5)
        elseif ind == 3
            f = (x[3] + 1) * (1 - (faux / (x[3] + 1))^0.1)
        end

    elseif PROBLEM == "Far1"
        if ind == 1
            f = -2 * exp(15 * (-(x[1] - 0.1)^2 - x[2]^2)) -
                exp(20 * (-(x[1] - 0.6)^2 - (x[2] - 0.6)^2)) +
                exp(20 * (-(x[1] + 0.6)^2 - (x[2] - 0.6)^2)) +
                exp(20 * (-(x[1] - 0.6)^2 - (x[2] + 0.6)^2)) +
                exp(20 * (-(x[1] + 0.6)^2 - (x[2] + 0.6)^2))
        elseif ind == 2
            f = 2 * exp(20 * (-(x[1]^2 + x[2]^2))) +
                exp(20 * (-(x[1] - 0.4)^2 - (x[2] - 0.6)^2)) -
                exp(20 * (-(x[1] + 0.5)^2 - (x[2] - 0.7)^2)) -
                exp(20 * (-(x[1] - 0.5)^2 - (x[2] + 0.7)^2)) +
                exp(20 * (-(x[1] + 0.4)^2 - (x[2] + 0.8)^2))
        end

    elseif PROBLEM == "FDS"
        if ind == 1
            f = sum([i * (x[i] - i)^4 for i in 1:n]) / n^2
        elseif ind == 2
            f = exp(sum(x) / n) + sum(x.^2)
        elseif ind == 3
            f = sum([i * (n - i + 1) * exp(-x[i]) for i in 1:n]) / (n * (n + 1))
        end

    elseif PROBLEM == "FF1"
        if ind == 1
            f = 1 - exp(-(x[1] - 1)^2 - (x[2] + 1)^2)
        elseif ind == 2
            f = 1 - exp(-(x[1] + 1)^2 - (x[2] - 1)^2)
        end

    elseif PROBLEM == "Hil1"
        a = 2π / 360 * (45 + 40 * sin(2π * x[1]) + 25 * sin(2π * x[2]))
        b = 1 + 0.5 * cos(2π * x[1])
        if ind == 1
            f = cos(a) * b
        elseif ind == 2
            f = sin(a) * b
        end

    elseif PROBLEM == "IKK1"
        if ind == 1
            f = x[1]^2
        elseif ind == 2
            f = (x[1] - 20)^2
        elseif ind == 3
            f = x[2]^2
        end

    elseif PROBLEM == "IM1"
        if ind == 1
            f = 2 * sqrt(x[1])
        elseif ind == 2
            f = x[1] * (1 - x[2]) + 5
        end

    elseif PROBLEM == "JOS1"
        if ind == 1
            f = 0.0
            for i in 1:n
                f += x[i]^2
            end
            f /= n
        elseif ind == 2
            f = 0.0
            for i in 1:n
                f += (x[i] - 2.0)^2
            end
            f /= n
        end
    
    elseif PROBLEM == "JOS4"
        if ind == 1
            f = x[1]
        elseif ind == 2
            faux = 1.0 + 9.0 * sum(x[2:n]) / (n - 1)
            f = faux * (1.0 - (x[1] / faux)^0.25 - (x[1] / faux)^4.0)
        end

    elseif PROBLEM == "KW2"
        if ind == 1
            f = -3.0 * (1.0 - x[1])^2 * exp(-x[1]^2 - (x[2] + 1.0)^2) +
                10.0 * (x[1] / 5.0 - x[1]^3 - x[2]^5) * exp(-x[1]^2 - x[2]^2) +
                3.0 * exp(-(x[1] + 2.0)^2 - x[2]^2) - 0.5 * (2.0 * x[1] + x[2])
        elseif ind == 2
            f = -3.0 * (1.0 + x[2])^2 * exp(-x[2]^2 - (1.0 - x[1])^2) +
                10.0 * (-x[2] / 5.0 + x[2]^3 + x[1]^5) * exp(-x[1]^2 - x[2]^2) +
                3.0 * exp(-(2.0 - x[2])^2 - x[1]^2)
        end

    elseif PROBLEM == "LE1"
        if ind == 1
            f = (x[1]^2 + x[2]^2)^0.125
        elseif ind == 2
            f = ((x[1] - 0.5)^2 + (x[2] - 0.5)^2)^0.25
        end

    elseif PROBLEM == "Lov1"
        if ind == 1
            f = -(-1.05 * x[1]^2 - 0.98 * x[2]^2)
        elseif ind == 2
            f = -(-0.99 * (x[1] - 3.0)^2 - 1.03 * (x[2] - 2.5)^2)
        end

    elseif PROBLEM == "Lov2"
        if ind == 1
            f = x[2]
        elseif ind == 2
            f = -(x[2] - x[1]^3) / (x[1] + 1.0)
        end

    elseif PROBLEM == "Lov3"
        if ind == 1
            f = -(-x[1]^2 - x[2]^2)
        elseif ind == 2
            f = -(- (x[1] - 6.0)^2 + (x[2] + 0.3)^2)
        end

    elseif PROBLEM == "Lov4"
        if ind == 1
            f = -x[1]^2 - x[2]^2 - 4.0 * (exp(-(x[1] + 2.0)^2 - x[2]^2) +
                 exp(-(x[1] - 2.0)^2 - x[2]^2))
            f = -f
        elseif ind == 2
            f = -(x[1] - 6.0)^2 - (x[2] + 0.5)^2
            f = -f
        end

    elseif PROBLEM == "Lov5"
        M = [-1.0  -0.03   0.011;
             -0.03 -1.0    0.07;
              0.011 0.07  -1.01]

        p = [x[1], x[2] - 0.15, x[3]]
        a = 0.35
        A1 = sqrt(2.0 * π / a) * exp(dot(p, M * p) / a^2)

        p = [x[1], x[2] + 1.1, 0.5 * x[3]]
        a = 3.0
        A2 = sqrt(2.0 * π / a) * exp(dot(p, M * p) / a^2)

        faux = A1 + A2

        if ind == 1
            f = sqrt(2.0) / 2.0 * (x[1] + faux)
            f = -f
        elseif ind == 2
            f = sqrt(2.0) / 2.0 * (-x[1] + faux)
            f = -f
        end

    elseif PROBLEM == "Lov6"
        if ind == 1
            f = x[1]
        elseif ind == 2
            f = 1.0 - sqrt(x[1]) - x[1] * sin(10.0 * π * x[1]) +
                x[2]^2 + x[3]^2 + x[4]^2 + x[5]^2 + x[6]^2
        end
    
    elseif PROBLEM == "LTDZ"
        if ind == 1
            f = -(3.0 - (1.0 + x[3]) * cos(x[1] * π / 2.0) * cos(x[2] * π / 2.0))
        elseif ind == 2
            f = -(3.0 - (1.0 + x[3]) * cos(x[1] * π / 2.0) * sin(x[2] * π / 2.0))
        elseif ind == 3
            f = -(3.0 - (1.0 + x[3]) * cos(x[1] * π / 2.0) * sin(x[1] * π / 2.0))
        end

    elseif PROBLEM == "MGH9"
        if ind == 1 || ind == 15
            y = 9.0e-4
        elseif ind == 2 || ind == 14
            y = 4.4e-3
        elseif ind == 3 || ind == 13
            y = 1.75e-2
        elseif ind == 4 || ind == 12
            y = 5.4e-2
        elseif ind == 5 || ind == 11
            y = 1.295e-1
        elseif ind == 6 || ind == 10
            y = 2.42e-1
        elseif ind == 7 || ind == 9
            y = 3.521e-1
        elseif ind == 8
            y = 3.989e-1
        end
        t = (8.0 - ind) / 2.0
        f = x[1] * exp(-x[2] * (t - x[3])^2 / 2.0) - y

    elseif PROBLEM == "MGH16"
        t = ind / 5.0
        f = (x[1] + t * x[2] - exp(t))^2 + (x[3] + x[4] * sin(t) - cos(t))^2

    elseif PROBLEM == "MGH26"
        t = sum(cos.(x))
        f = (n - t + ind * (1.0 - cos(x[ind])) - sin(x[ind]))^2

    elseif PROBLEM == "MGH33"
        faux = sum(i * x[i] for i in 1:n)
        f = (ind * faux - 1.0)^2

    elseif PROBLEM == "MHHM2"
        if ind == 1
            f = (x[1] - 0.8)^2 + (x[2] - 0.6)^2
        elseif ind == 2
            f = (x[1] - 0.85)^2 + (x[2] - 0.7)^2
        elseif ind == 3
            f = (x[1] - 0.9)^2 + (x[2] - 0.6)^2
        end

    elseif PROBLEM == "MLF1"
        if ind == 1
            f = (1.0 + x[1] / 20.0) * sin(x[1])
        elseif ind == 2
            f = (1.0 + x[1] / 20.0) * cos(x[1])
        end

    elseif PROBLEM == "MLF2"
        if ind == 1
            f = -(5.0 - ((x[1]^2 + x[2] - 11.0)^2 + (x[1] + x[2]^2 - 7.0)^2) / 200.0)
        elseif ind == 2
            f = -(5.0 - ((4.0 * x[1]^2 + 2.0 * x[2] - 11.0)^2 + (2.0 * x[1] + 4.0 * x[2]^2 - 7.0)^2) / 200.0)
        end

    elseif PROBLEM == "MMR1"
        if ind == 1
            f = 1.0 + x[1]^2
        elseif ind == 2
            f = (2.0 - 0.8 * exp(-((x[2] - 0.6) / 0.4)^2) - exp(-((x[2] - 0.2) / 0.04)^2)) / (1.0 + x[1]^2)
        end

    elseif PROBLEM == "MMR3"
        if ind == 1
            f = x[1]^3
        elseif ind == 2
            f = (x[2] - x[1])^3
        end

    elseif PROBLEM == "MMR4"
        if ind == 1
            f = x[1] - 2.0 * x[2] - x[3] - 36.0 / (2.0 * x[1] + x[2] + 2.0 * x[3] + 1.0)
        elseif ind == 2
            f = -3.0 * x[1] + x[2] - x[3]
        end

    elseif PROBLEM == "MOP2"
        if ind == 1
            f = 1.0 - exp(-sum((x[i] - 1.0 / sqrt(n))^2 for i in 1:n))
        elseif ind == 2
            f = 1.0 - exp(-sum((x[i] + 1.0 / sqrt(n))^2 for i in 1:n))
        end

    elseif PROBLEM == "MOP3"
        if ind == 1
            A1 = 0.5 * sin(1.0) - 2.0 * cos(1.0) + sin(2.0) - 1.5 * cos(2.0)
            A2 = 1.5 * sin(1.0) - cos(1.0) + 2.0 * sin(2.0) - 0.5 * cos(2.0)
            B1 = 0.5 * sin(x[1]) - 2.0 * cos(x[1]) + sin(x[2]) - 1.5 * cos(x[2])
            B2 = 1.5 * sin(x[1]) - cos(x[1]) + 2.0 * sin(x[2]) - 0.5 * cos(x[2])
            f = -(-1.0 - (A1 - B1)^2 - (A2 - B2)^2)
        elseif ind == 2
            f = -(-(x[1] + 3.0)^2 - (x[2] + 1.0)^2)
        end

    elseif PROBLEM == "MOP5"
        if ind == 1
            f = 0.5 * (x[1]^2 + x[2]^2) + sin(x[1]^2 + x[2]^2)
        elseif ind == 2
            f = (3.0 * x[1] - 2.0 * x[2] + 4.0)^2 / 8.0 + (x[1] - x[2] + 1.0)^2 / 27.0 + 15.0
        elseif ind == 3
            f = 1.0 / (x[1]^2 + x[2]^2 + 1.0) - 1.1 * exp(-x[1]^2 - x[2]^2)
        end

    elseif PROBLEM == "MOP6"
        if ind == 1
            f = x[1]
        elseif ind == 2
            a = 1.0 + 10.0 * x[2]
            t = x[1] / a
            f = a * (1.0 - t^2 - t * sin(8.0 * π * x[1]))
        end

    elseif PROBLEM == "MOP7"
        if ind == 1
            f = (x[1] - 2.0)^2 / 2.0 + (x[2] + 1.0)^2 / 13.0 + 3.0
        elseif ind == 2
            f = (x[1] + x[2] - 3.0)^2 / 36.0 + (-x[1] + x[2] + 2.0)^2 / 8.0 - 17.0
        elseif ind == 3
            f = (x[1] + 2.0 * x[2] - 1.0)^2 / 175.0 + (-x[1] + 2.0 * x[2])^2 / 17.0 - 13.0
        end

    elseif PROBLEM == "PNR"
        if ind == 1
            f = x[1]^4 + x[2]^4 - x[1]^2 + x[2]^2 - 10.0 * x[1] * x[2] + 20.0
        elseif ind == 2
            f = x[1]^2 + x[2]^2
        end

    elseif PROBLEM == "QV1"
        if ind == 1
            f = (sum(x[i]^2 - 10.0 * cos(2.0 * π * x[i]) + 10.0 for i in 1:n) / n)^0.25
        elseif ind == 2
            f = (sum((x[i] - 1.5)^2 - 10.0 * cos(2.0 * π * (x[i] - 1.5)) + 10.0 for i in 1:n) / n)^0.25
        end

    elseif PROBLEM == "SD"
        if ind == 1
            f = 2.0 * x[1] + sqrt(2.0) * (x[2] + x[3]) + x[4]
        elseif ind == 2
            f = 2.0 / x[1] + 2.0 * sqrt(2.0) / x[2] + 2.0 * sqrt(2.0) / x[3] + 2.0 / x[4]
        end

    elseif PROBLEM == "SLCDT1"
        if ind == 1
            f = 0.5 * (sqrt(1.0 + (x[1] + x[2])^2) + sqrt(1.0 + (x[1] - x[2])^2) + x[1] - x[2]) +
                0.85 * exp(-(x[1] + x[2])^2)
        elseif ind == 2
            f = 0.5 * (sqrt(1.0 + (x[1] + x[2])^2) + sqrt(1.0 + (x[1] - x[2])^2) - x[1] + x[2]) +
                0.85 * exp(-(x[1] + x[2])^2)
        end

    elseif PROBLEM == "SLCDT2"
        if ind == 1
            f = (x[1] - 1.0)^4 + sum((x[i] - 1.0)^2 for i in 2:n)
        elseif ind == 2
            f = (x[2] + 1.0)^4 + sum((x[i] + 1.0)^2 for i in 1:n if i != 2)
        elseif ind == 3
            f = (x[3] - 1.0)^4 + sum((x[i] - (-1.0)^(i + 1))^2 for i in 1:n if i != 3)
        end

    elseif PROBLEM == "SP1"
        if ind == 1
            f = (x[1] - 1.0)^2 + (x[1] - x[2])^2
        elseif ind == 2
            f = (x[2] - 3.0)^2 + (x[1] - x[2])^2
        end

    elseif PROBLEM == "SSFYY2"
        if ind == 1
            f = 10.0 + x[1]^2 - 10.0 * cos(x[1] * π / 2.0)
        elseif ind == 2
            f = (x[1] - 4.0)^2
        end

    elseif PROBLEM == "SK1"
        if ind == 1
            f = -(-x[1]^4 - 3.0 * x[1]^3 + 10.0 * x[1]^2 + 10.0 * x[1] + 10.0)
        elseif ind == 2
            f = -(-0.5 * x[1]^4 + 2.0 * x[1]^3 + 10.0 * x[1]^2 - 10.0 * x[1] + 5.0)
        end

    elseif PROBLEM == "SK2"
        if ind == 1
            f = -(-(x[1] - 2.0)^2 - (x[2] + 3.0)^2 - (x[3] - 5.0)^2 - (x[4] - 4.0)^2 + 5.0)
        elseif ind == 2
            f = -((sin(x[1]) + sin(x[2]) + sin(x[3]) + sin(x[4])) /
                (1.0 + (x[1]^2 + x[2]^2 + x[3]^2 + x[4]^2) / 100.0))
        end

    elseif PROBLEM == "TKLY1"
        if ind == 1
            f = x[1]
        elseif ind == 2
            A1 = (2.0 - exp(-((x[2] - 0.1) / 0.004)^2) - 0.8 * exp(-((x[2] - 0.9) / 0.4)^2))
            A2 = (2.0 - exp(-((x[3] - 0.1) / 0.004)^2) - 0.8 * exp(-((x[3] - 0.9) / 0.4)^2))
            A3 = (2.0 - exp(-((x[4] - 0.1) / 0.004)^2) - 0.8 * exp(-((x[4] - 0.9) / 0.4)^2))
            f = A1 * A2 * A3 / x[1]
        end

    elseif PROBLEM == "Toi4"
        if ind == 1
            f = x[1]^2 + x[2]^2 + 1.0
        elseif ind == 2
            f = 0.5 * ((x[1] - x[2])^2 + (x[3] - x[4])^2) + 1.0
        end

    elseif PROBLEM == "Toi8"
        if ind == 1
            f = (2.0 * x[1] - 1.0)^2
        elseif ind != 1
            f = ind * (2.0 * x[ind - 1] - x[ind])^2
        end

    elseif PROBLEM == "Toi9"
        if ind == 1
            f = (2.0 * x[1] - 1.0)^2 + x[2]^2
        elseif ind > 1 && ind < n
            f = ind * (2.0 * x[ind - 1] - x[ind])^2 - (ind - 1.0) * x[ind - 1]^2 + ind * x[ind]^2
        elseif ind == n
            f = n * (2.0 * x[n - 1] - x[n])^2 - (n - 1.0) * x[n - 1]^2
        end

    elseif PROBLEM == "Toi10"
        f = 100.0 * (x[ind + 1] - x[ind]^2)^2 + (x[ind + 1] - 1.0)^2

    elseif PROBLEM == "VU1"
        if ind == 1
            f = 1.0 / (x[1]^2 + x[2]^2 + 1.0)
        elseif ind == 2
            f = x[1]^2 + 3.0 * x[2]^2 + 1.0
        end

    elseif PROBLEM == "VU2"
        if ind == 1
            f = x[1] + x[2] + 1.0
        elseif ind == 2
            f = x[1]^2 + 2.0 * x[2] - 1.0
        end

    elseif PROBLEM == "ZDT1"
        if ind == 1
            f = x[1]
        elseif ind == 2
            faux = 1.0 + 9.0 * sum(x[2:n]) / (n - 1)
            f = faux * (1.0 - sqrt(x[1] / faux))
        end

    elseif PROBLEM == "ZDT2"
        if ind == 1
            f = x[1]
        elseif ind == 2
            faux = 1.0 + 9.0 * sum(x[2:n]) / (n - 1)
            f = faux * (1.0 - (x[1] / faux)^2)
        end

    elseif PROBLEM == "ZDT3"
        if ind == 1
            f = x[1]
        elseif ind == 2
            faux = 1.0 + 9.0 * sum(x[2:n]) / (n - 1)
            t = x[1] / faux
            f = faux * (1.0 - sqrt(t) - t * sin(10.0 * π * x[1]))
        end

    elseif PROBLEM == "ZDT4"
        if ind == 1
            f = x[1]
        elseif ind == 2
            faux = sum(x[i]^2 - 10.0 * cos(4.0 * π * x[i]) for i in 2:n) + 1.0 + 10.0 * (n - 1)
            t = x[1] / faux
            f = faux * (1.0 - sqrt(t))
        end

    elseif PROBLEM == "ZDT6"
        if ind == 1
            f = 1.0 - exp(-4.0 * x[1]) * (sin(6.0 * π * x[1]))^6
        elseif ind == 2
            t = 1.0 + 9.0 * (sum(x[2:n]) / (n - 1))^0.25
            f = t * (1.0 - ((1.0 - exp(-4.0 * x[1]) * (sin(6.0 * π * x[1]))^6) / t)^2)
        end

    elseif PROBLEM == "ZLT1"
        f = (x[ind] - 1.0)^2 + sum(x[i]^2 for i in 1:n if i != ind)

    else
        error("Unknown problem : $PROBLEM")
    end

    return f
end

# ======================================================================
# Gradient ∇f_i(x)
# ======================================================================
"""
--------------------------------------------------------------------------------
evalg! — Gradient evaluation (in-place)
--------------------------------------------------------------------------------

Computes the gradient ∇f_ind(x) of the selected objective function and stores
the result in-place in the vector `g`.

--------------------------------------------------------------------------------
Inputs:

    ind :: Int        → Objective function index
    x   :: Vector{T} → Current point
    n   :: Int        → Number of variables

--------------------------------------------------------------------------------
In-place Output:

    g :: Vector{T}   → Gradient ∇f_ind(x)

--------------------------------------------------------------------------------
"""
function evalg!(g::Vector{T}, ind::Int, x::Vector{T}, n::Int) where {T<:AbstractFloat}

    fill!(g, ZERO)

    if PROBLEM == "F1"
        x1 = x[1]
        J1 = 0
        J2 = 0

        # First pass: count J1 and J2
        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        if ind == 1
            # f1 = x1 + (2/J1) * Σ_{j odd} y_j^2,   y_j = x_j - x1^a_j
            acc = ZERO  # accumulates Σ a_j * y_j * x1^(a_j-1)

            for j in 2:n
                if isodd(j)
                    a  = T(0.5) * (ONE + T(3) * T(j - 2) / T(n - 2))
                    xa = x1^a
                    y  = x[j] - xa

                    # ∂f1/∂xj = (4/J1) * y
                    g[j] = (T(4) / T(J1)) * y

                    # contribution to ∂f1/∂x1 from this j:
                    # dy/dx1 = -a*x1^(a-1)
                    acc += a * y * x1^(a - ONE)
                end
            end

            # ∂f1/∂x1 = 1 + (2/J1)*Σ 2y * dy/dx1 = 1 - (4/J1)*Σ a*y*x1^(a-1)
            g[1] = ONE - (T(4) / T(J1)) * acc

        elseif ind == 2
            # f2 = 1 - sqrt(x1) + (2/J2) * Σ_{j even} y_j^2
            acc = ZERO

            for j in 2:n
                if iseven(j)
                    a  = T(0.5) * (ONE + T(3) * T(j - 2) / T(n - 2))
                    xa = x1^a
                    y  = x[j] - xa

                    g[j] = (T(4) / T(J2)) * y
                    acc += a * y * x1^(a - ONE)
                end
            end

            # derivative of 1 - sqrt(x1)
            g[1] = -inv(T(2) * sqrt(x1)) - (T(4) / T(J2)) * acc
        end

    elseif PROBLEM == "F2"

        x1 = x[1]
        sum1 = ZERO
        sum2 = ZERO
        J1 = 0
        J2 = 0

        for j in 2:n
            θ = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
            y = x[j] - sin(θ)
            c = cos(θ)

            if isodd(j)
                J1 += 1
                if ind == 1
                    sum1 += y * c
                end
            else
                J2 += 1
                if ind == 2
                    sum2 += y * c
                end
            end
        end

        if ind == 1
            g[1] = 1 - (24*T(pi)/T(J1)) * sum1
        elseif ind == 2
            g[1] = -inv(2*sqrt(x1)) - (24*T(pi)/T(J2)) * sum2
        end

        for j in 2:n
            θ = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
            y = x[j] - sin(θ)

            if ind == 1 && isodd(j)
                g[j] = (4 / T(J1)) * y
            elseif ind == 2 && iseven(j)
                g[j] = (4 / T(J2)) * y
            end
        end

    elseif PROBLEM == "F3"
        x1 = x[1]
        J1 = 0
        J2 = 0

        # Count J1 and J2
        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        if ind == 1
            acc = ZERO   # accumulator for ∂f/∂x1 contributions

            for j in 2:n
                θ = T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)

                if isodd(j)
                    y = x[j] - T(0.8) * x1 * cos(θ)

                    # ∂f/∂xj
                    g[j] = (T(4) / T(J1)) * y

                    # dy/dx1 = -0.8*cos(θ) + 0.8*x1*sin(θ)*6π
                    dy1 = -T(0.8) * cos(θ) + T(0.8) * x1 * sin(θ) * T(6) * T(pi)

                    acc += y * dy1
                end
            end

            # ∂f/∂x1
            g[1] = ONE + (T(4) / T(J1)) * acc

        elseif ind == 2
            acc = ZERO

            for j in 2:n
                θ = T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)

                if iseven(j)
                    y = x[j] - T(0.8) * x1 * sin(θ)

                    g[j] = (T(4) / T(J2)) * y

                    # dy/dx1 = -0.8*sin(θ) - 0.8*x1*cos(θ)*6π
                    dy1 = -T(0.8) * sin(θ) - T(0.8) * x1 * cos(θ) * T(6) * T(pi)

                    acc += y * dy1
                end
            end

            # derivative of 1 - sqrt(x1)
            g[1] = -inv(T(2) * sqrt(x1)) + (T(4) / T(J2)) * acc
        end
    
    elseif PROBLEM == "F4"
        x1 = x[1]
        J1 = 0
        J2 = 0

        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        if ind == 1
            acc = ZERO

            for j in 2:n
                if isodd(j)
                    θ1 = (T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)) / T(3)
                    y  = x[j] - T(0.8) * x1 * cos(θ1)

                    # ∂f/∂xj
                    g[j] = (T(4) / T(J1)) * y

                    # dy/dx1 = -0.8*cos(θ1) + 0.8*x1*sin(θ1)*(6π/3)
                    dy1 = -T(0.8) * cos(θ1) +
                        T(0.8) * x1 * sin(θ1) * (T(6) * T(pi) / T(3))

                    acc += y * dy1
                end
            end

            g[1] = ONE + (T(4) / T(J1)) * acc

        elseif ind == 2
            acc = ZERO

            for j in 2:n
                if iseven(j)
                    θ2 = T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)
                    y  = x[j] - T(0.8) * x1 * sin(θ2)

                    g[j] = (T(4) / T(J2)) * y

                    # dy/dx1 = -0.8*sin(θ2) - 0.8*x1*cos(θ2)*6π
                    dy1 = -T(0.8) * sin(θ2) -
                        T(0.8) * x1 * cos(θ2) * T(6) * T(pi)

                    acc += y * dy1
                end
            end

            g[1] = -inv(T(2) * sqrt(x1)) + (T(4) / T(J2)) * acc
        end

    elseif PROBLEM == "F5"

        x1 = x[1]

        J1 = 0
        J2 = 0
        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        sum1 = ZERO
        sum2 = ZERO

        for j in 2:n
            θ1 = 24*T(pi)*x1 + 4*T(j)*T(pi)/T(n)
            θ2 =  6*T(pi)*x1 +     T(j)*T(pi)/T(n)

            A  = 0.3*x1^2 * cos(θ1) + 0.6*x1
            dA = 0.6*x1 * cos(θ1) - 7.2*T(pi)*x1^2 * sin(θ1) + 0.6

            if isodd(j)
                y  = x[j] - A * cos(θ2)
                dy = -dA * cos(θ2) + 6*T(pi)*A * sin(θ2)

                if ind == 1
                    sum1 += y * dy
                    g[j]  = (4 / T(J1)) * y
                end
            else
                y  = x[j] - A * sin(θ2)
                dy = -dA * sin(θ2) - 6*T(pi)*A * cos(θ2)

                if ind == 2
                    sum2 += y * dy
                    g[j]  = (4 / T(J2)) * y
                end
            end
        end

        if ind == 1
            g[1] = 1 + (4 / T(J1)) * sum1
        elseif ind == 2
            g[1] = -inv(2*sqrt(x1)) + (4 / T(J2)) * sum2
        end

    elseif PROBLEM == "F6"

        x1 = x[1]
        x2 = x[2]

        # Trigonometric terms of the front
        c1 = cos(T(pi)/T(2) * x1)
        s1 = sin(T(pi)/T(2) * x1)
        c2 = cos(T(pi)/T(2) * x2)
        s2 = sin(T(pi)/T(2) * x2)

        dc1 = -T(pi)/T(2) * s1
        ds1 =  T(pi)/T(2) * c1
        dc2 = -T(pi)/T(2) * s2
        ds2 =  T(pi)/T(2) * c2

        # Count indices in J1, J2, J3
        J1 = 0
        J2 = 0
        J3 = 0
        for j in 3:n
            r = mod(j-1, 3)
            r == 0 ? (J1 += 1) : (r == 1 ? (J2 += 1) : (J3 += 1))
        end

        sumx1 = ZERO
        sumx2 = ZERO

        for j in 3:n
            θ  = T(2)*T(pi)*x1 + T(j)*T(pi)/T(n)
            sθ = sin(θ)
            cθ = cos(θ)

            # Correct y_j
            y = x[j] - T(2)*x2*sθ

            # First derivatives of y_j
            dy_dx1 = -T(4)*T(pi)*x2*cθ
            dy_dx2 = -T(2)*sθ

            r = mod(j-1, 3)

            if ind == 1 && r == 0
                g[j] = (T(4) / T(J1)) * y
                sumx1 += T(2) * y * dy_dx1
                sumx2 += T(2) * y * dy_dx2

            elseif ind == 2 && r == 1
                g[j] = (T(4) / T(J2)) * y
                sumx1 += T(2) * y * dy_dx1
                sumx2 += T(2) * y * dy_dx2

            elseif ind == 3 && r == 2
                g[j] = (T(4) / T(J3)) * y
                sumx1 += T(2) * y * dy_dx1
                sumx2 += T(2) * y * dy_dx2
            end
        end

        if ind == 1
            g[1] = dc1*c2 + (T(2) / T(J1)) * sumx1
            g[2] = c1*dc2 + (T(2) / T(J1)) * sumx2

        elseif ind == 2
            g[1] = dc1*s2 + (T(2) / T(J2)) * sumx1
            g[2] = c1*ds2 + (T(2) / T(J2)) * sumx2

        elseif ind == 3
            g[1] = ds1 + (T(2) / T(J3)) * sumx1
            g[2] = (T(2) / T(J3)) * sumx2
        end

    elseif PROBLEM == "F7"
        x1 = x[1]
        J1 = 0
        J2 = 0

        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        if ind == 1
            acc = ZERO

            for j in 2:n
                if isodd(j)
                    a  = T(0.5) * (ONE + T(3) * T(j - 2) / T(n - 2))
                    xa = x1^a
                    y  = x[j] - xa

                    # dφ/dy = 8y + 8π sin(8πy)
                    dφ = T(8) * y + T(8) * T(pi) * sin(T(8) * T(pi) * y)

                    # ∂f/∂xj
                    g[j] = (T(2) / T(J1)) * dφ

                    # dy/dx1 = -a*x1^(a-1)
                    acc += dφ * (-a * x1^(a - ONE))
                end
            end

            g[1] = ONE + (T(2) / T(J1)) * acc

        elseif ind == 2
            acc = ZERO

            for j in 2:n
                if iseven(j)
                    a  = T(0.5) * (ONE + T(3) * T(j - 2) / T(n - 2))
                    xa = x1^a
                    y  = x[j] - xa

                    dφ = T(8) * y + T(8) * T(pi) * sin(T(8) * T(pi) * y)

                    g[j] = (T(2) / T(J2)) * dφ
                    acc += dφ * (-a * x1^(a - ONE))
                end
            end

            g[1] = -inv(T(2) * sqrt(x1)) + (T(2) / T(J2)) * acc
        end

    elseif PROBLEM == "F8"

        x1 = x[1]

        # First pass: counts and precomputations
        J1 = 0
        J2 = 0

        # Pre-allocated arrays (only indices 2..n are used)
        y    = Vector{T}(undef, n)
        dy1  = Vector{T}(undef, n)   # dy/dx1
        φ    = Vector{T}(undef, n)
        tanφ = Vector{T}(undef, n)
        cosφ = Vector{T}(undef, n)

        S1 = ZERO
        S2 = ZERO
        P1 = ONE
        P2 = ONE

        sum_y_dy1_J1 = ZERO   # Σ (y_j * dy_j/dx1) for j in J1
        sum_y_dy1_J2 = ZERO   # Σ (y_j * dy_j/dx1) for j in J2
        sum_A1       = ZERO   # Σ ( -tanφ_j * φ'_j(x1) ) for j in J1
        sum_A2       = ZERO   # Σ ( -tanφ_j * φ'_j(x1) ) for j in J2

        for j in 2:n
            # alpha_j
            α = T(0.5) * (ONE + T(3) * (T(j-2) / T(n-2)))

            x1α = x1^α
            yj  = x[j] - x1α

            # dy/dx1 = -α * x1^(α-1)
            dy1j = -α * x1^(α - ONE)

            φj   = 20*T(pi) * yj / sqrt(T(j))
            cφj  = cos(φj)
            sφj  = sin(φj)
            tφj  = sφj / cφj

            # φ'(x1) = 20π / sqrt(j) * dy/dx1
            φ1j = 20*T(pi) / sqrt(T(j)) * dy1j

            y[j]    = yj
            dy1[j]  = dy1j
            φ[j]    = φj
            tanφ[j] = tφj
            cosφ[j] = cφj

            if isodd(j)
                J1 += 1
                S1 += yj^2
                P1 *= cφj

                sum_y_dy1_J1 += yj * dy1j
                sum_A1       += -tφj * φ1j
            else
                J2 += 1
                S2 += yj^2
                P2 *= cφj

                sum_y_dy1_J2 += yj * dy1j
                sum_A2       += -tφj * φ1j
            end
        end

        # Gradients

        if ind == 1
            c1 = 2 / T(J1)

            # derivative w.r.t x1
            dS1_dx1 = 2 * sum_y_dy1_J1         # Σ 2 y_j dy_j/dx1
            dP1_dx1 = P1 * sum_A1

            g[1] = ONE + c1 * (4*dS1_dx1 - 2*dP1_dx1)

            # derivatives w.r.t x_j, j in J1
            for j in 2:n
                if isodd(j)
                    yj = y[j]

                    # dS1/dxj = 2 yj
                    dS1_dxj = 2 * yj

                    # φ'_j(xj) = 20π / sqrt(j) * dy/dxj, and dy/dxj = 1
                    φj_xj   = 20*T(pi) / sqrt(T(j))
                    dP1_dxj = P1 * (-tanφ[j] * φj_xj)

                    g[j] = c1 * (4*dS1_dxj - 2*dP1_dxj)
                end
            end

        elseif ind == 2
            c2 = 2 / T(J2)

            # derivative w.r.t x1
            dS2_dx1 = 2 * sum_y_dy1_J2
            dP2_dx1 = P2 * sum_A2

            g[1] = -T(0.5) / sqrt(x1) + c2 * (4*dS2_dx1 - 2*dP2_dx1)

            # derivatives w.r.t x_j, j in J2
            for j in 2:n
                if iseven(j)
                    yj = y[j]

                    dS2_dxj = 2 * yj

                    φj_xj   = 20*T(pi) / sqrt(T(j))
                    dP2_dxj = P2 * (-tanφ[j] * φj_xj)

                    g[j] = c2 * (4*dS2_dxj - 2*dP2_dxj)
                end
            end
        end
    
    elseif PROBLEM == "F9"
        x1 = x[1]
        J1 = 0
        J2 = 0

        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        if ind == 1
            acc = ZERO

            for j in 2:n
                if isodd(j)
                    θ  = T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)
                    y  = x[j] - sin(θ)

                    # ∂f/∂xj
                    g[j] = (T(4) / T(J1)) * y

                    # dy/dx1 = -cos(θ) * dθ/dx1 = -cos(θ) * 6π
                    dy1 = -cos(θ) * T(6) * T(pi)
                    acc += y * dy1
                end
            end

            # ∂f/∂x1 = 1 + (4/J1) Σ y * dy/dx1
            g[1] = ONE + (T(4) / T(J1)) * acc

        elseif ind == 2
            acc = ZERO

            for j in 2:n
                if iseven(j)
                    θ  = T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)
                    y  = x[j] - sin(θ)

                    g[j] = (T(4) / T(J2)) * y

                    dy1 = -cos(θ) * T(6) * T(pi)
                    acc += y * dy1
                end
            end

            # derivative of 1 - x1^2 is -2x1
            g[1] = -T(2) * x1 + (T(4) / T(J2)) * acc
        end
    
    elseif PROBLEM == "CEC04"

        x1 = x[1]

        # First pass: correct counts for J1 and J2
        J1 = 0
        J2 = 0
        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        sum1x1 = ZERO   # Σ_{j∈J1} h'(y_j) * dy_j/dx1
        sum2x1 = ZERO   # Σ_{j∈J2} h'(y_j) * dy_j/dx1

        # Second pass: contributions to gradient
        for j in 2:n
            θ = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
            cθ = cos(θ)

            y = x[j] - sin(θ)
            a = abs(y)

            e2   = exp(T(2)*a)
            den  = ONE + e2
            dhda = (den - T(2)*a*e2) / (den*den)   # dh/da
            sgn  = sign(y)
            hprime = sgn * dhda                    # dh/dt

            dy_dx1 = -T(6)*T(pi)*cθ                # dy/dx1

            if isodd(j)
                if ind == 1
                    # derivative w.r.t x1
                    sum1x1 += hprime * dy_dx1
                    # derivative w.r.t x_j
                    g[j] = (T(2) / T(J1)) * hprime   # dy/dxj = 1
                end
            else
                if ind == 2
                    # derivative w.r.t x1
                    sum2x1 += hprime * dy_dx1
                    # derivative w.r.t x_j
                    g[j] = (T(2) / T(J2)) * hprime   # dy/dxj = 1
                end
            end
        end

        if ind == 1
            g[1] = ONE + (T(2) / T(J1)) * sum1x1
        elseif ind == 2
            g[1] = -T(2)*x1 + (T(2) / T(J2)) * sum2x1
        end

    elseif PROBLEM == "CEC05"

        x1 = x[1]

        # Parameters of the central term
        N   = T(10)
        eps = T(0.1)
        A   = inv(T(2)*N) + eps          # (1/(2N) + eps)

        # Central term derivative w.r.t x1
        s    = sin(T(2)*N*T(pi)*x1)
        c2N  = cos(T(2)*N*T(pi)*x1)
        dcterm_dx1 = A * T(2)*N*T(pi) * sign(s) * c2N

        # First pass: correct counts of J1 and J2
        J1 = 0
        J2 = 0
        for j in 2:n
            isodd(j) ? (J1 += 1) : (J2 += 1)
        end

        sum1x1 = ZERO
        sum2x1 = ZERO

        for j in 2:n
            θ  = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
            cθ = cos(θ)

            y = x[j] - sin(θ)

            # h'(y) = 4y + 4π sin(4π y)
            dhdy = T(4)*y + T(4)*T(pi)*sin(T(4)*T(pi)*y)

            dy_dx1 = -T(6)*T(pi)*cθ

            if isodd(j)
                if ind == 1
                    sum1x1 += dhdy * dy_dx1
                    g[j] = (T(2) / T(J1)) * dhdy
                end
            else
                if ind == 2
                    sum2x1 += dhdy * dy_dx1
                    g[j] = (T(2) / T(J2)) * dhdy
                end
            end
        end

        if ind == 1
            g[1] = ONE + dcterm_dx1 + (T(2) / T(J1)) * sum1x1
        elseif ind == 2
            g[1] = -ONE + dcterm_dx1 + (T(2) / T(J2)) * sum2x1
        end

    elseif PROBLEM == "CEC06"

        x1  = x[1]
        N   = T(2)
        eps = T(0.1)

        # Central "jump" term derivative w.r.t x1
        A     = T(2) * (inv(T(2)*N) + eps)
        s2N   = sin(T(2)*N*T(pi)*x1)
        c2N   = cos(T(2)*N*T(pi)*x1)
        inner = A * s2N

        dcterm_dx1 = inner > ZERO ? A * T(2)*N*T(pi) * c2N : ZERO

        # First pass: classify indices and prepare data
        J1 = 0
        J2 = 0
        for j in 2:n
            isodd(j) ? (J1 += 1) : (J2 += 1)
        end

        ys      = Vector{T}(undef, n)
        betas   = Vector{T}(undef, n)
        cosθs   = Vector{T}(undef, n)
        isJ1    = falses(n)
        isJ2    = falses(n)

        P1 = ONE
        P2 = ONE

        for j in 2:n
            θ = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
            cθ = cos(θ)

            y = x[j] - sin(θ)
            β = T(20)*T(pi) / sqrt(T(j))

            ys[j]    = y
            betas[j] = β
            cosθs[j] = cθ

            if isodd(j)
                isJ1[j] = true
                P1 *= cos(β * y)
            else
                isJ2[j] = true
                P2 *= cos(β * y)
            end
        end

        sum1x1 = ZERO
        sum2x1 = ZERO

        if ind == 1
            for j in 2:n
                if isJ1[j]
                    y  = ys[j]
                    β  = betas[j]
                    cθ = cosθs[j]

                    # dG/dy_j for the UF3-type term
                    t     = β * y
                    tan_t = tan(t)
                    dGdy  = T(8)*y + T(2)*P1*β*tan_t

                    # dy_j/dx1
                    dy_dx1 = -T(6)*T(pi)*cθ

                    # contribution to gradient
                    g[j] = (T(2) / T(J1)) * dGdy
                    sum1x1 += dGdy * dy_dx1
                end
            end

            g[1] = ONE + dcterm_dx1 + (T(2) / T(J1)) * sum1x1

        elseif ind == 2
            for j in 2:n
                if isJ2[j]
                    y  = ys[j]
                    β  = betas[j]
                    cθ = cosθs[j]

                    t     = β * y
                    tan_t = tan(t)
                    dGdy  = T(8)*y + T(2)*P2*β*tan_t

                    dy_dx1 = -T(6)*T(pi)*cθ

                    g[j] = (T(2) / T(J2)) * dGdy
                    sum2x1 += dGdy * dy_dx1
                end
            end

            g[1] = -ONE + dcterm_dx1 + (T(2) / T(J2)) * sum2x1
        end

    elseif PROBLEM == "CEC07"

        x1 = x[1]

        dx1p = (T(1)/T(5)) * x1^(-T(4)/T(5))   # derivative of x1^(1/5)

        # Count indices in J1 and J2
        J1 = 0
        J2 = 0
        for j in 2:n
            isodd(j) ? (J1 += 1) : (J2 += 1)
        end

        if ind == 1
            sum1x1 = ZERO

            for j in 2:n
                θ  = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
                cθ = cos(θ)
                sθ = sin(θ)

                y = x[j] - sθ

                if isodd(j)
                    # ∂f1/∂xj
                    g[j] = (T(4) / T(J1)) * y

                    # dyj/dx1
                    dy_dx1 = -T(6)*T(pi)*cθ

                    # Contribution to ∂f1/∂x1
                    sum1x1 += T(2) * y * dy_dx1
                end
            end

            g[1] = dx1p + (T(2) / T(J1)) * sum1x1

        elseif ind == 2
            sum2x1 = ZERO

            for j in 2:n
                θ  = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
                cθ = cos(θ)
                sθ = sin(θ)

                y = x[j] - sθ

                if iseven(j)
                    # ∂f2/∂xj
                    g[j] = (T(4) / T(J2)) * y

                    dy_dx1 = -T(6)*T(pi)*cθ

                    sum2x1 += T(2) * y * dy_dx1
                end
            end

            g[1] = -dx1p + (T(2) / T(J2)) * sum2x1
        end

    elseif PROBLEM == "CEC09"

        x1 = x[1]
        x2 = x[2]

        eps = T(0.1)

        z  = T(2)*x1 - ONE
        g0 = (ONE + eps) * (ONE - T(4)*z^2)

        active = g0 > ZERO

        dg_dx1 = active ? (ONE + eps)*(-T(16)*z) : ZERO

        J1 = 0; J2 = 0; J3 = 0
        for j in 3:n
            r = mod(j-1, 3)
            r == 0 ? (J1 += 1) : (r == 1 ? (J2 += 1) : (J3 += 1))
        end

        sumx1 = ZERO
        sumx2 = ZERO

        for j in 3:n
            θ  = T(2)*T(pi)*x1 + T(j)*T(pi)/T(n)
            sθ = sin(θ)
            cθ = cos(θ)

            y = x[j] - T(2)*x2*sθ

            dy_dx1 = -T(4)*T(pi)*x2*cθ
            dy_dx2 = -T(2)*sθ

            r = mod(j-1, 3)

            if ind == 1 && r == 0
                g[j] = (T(4)/T(J1))*y
                sumx1 += T(2)*y*dy_dx1
                sumx2 += T(2)*y*dy_dx2

            elseif ind == 2 && r == 1
                g[j] = (T(4)/T(J2))*y
                sumx1 += T(2)*y*dy_dx1
                sumx2 += T(2)*y*dy_dx2

            elseif ind == 3 && r == 2
                g[j] = (T(4)/T(J3))*y
                sumx1 += T(2)*y*dy_dx1
                sumx2 += T(2)*y*dy_dx2
            end
        end

        if ind == 1
            g[1] = T(0.5)*(dg_dx1 + T(2))*x2 + (T(2)/T(J1))*sumx1
            g[2] = T(0.5)*(active ? g0 + T(2)*x1 : T(2)*x1) + (T(2)/T(J1))*sumx2

        elseif ind == 2
            g[1] = T(0.5)*(dg_dx1 - T(2))*x2 + (T(2)/T(J2))*sumx1
            g[2] = T(0.5)*(active ? g0 - T(2)*x1 + T(2) : -T(2)*x1 + T(2)) + (T(2)/T(J2))*sumx2

        elseif ind == 3
            g[2] = -ONE + (T(2)/T(J3))*sumx2
            g[1] = (T(2)/T(J3))*sumx1
        end

    elseif PROBLEM == "CEC10"

        x1 = x[1]
        x2 = x[2]

        # Front trigonometric terms
        c1 = cos(T(pi)/T(2) * x1)
        s1 = sin(T(pi)/T(2) * x1)
        c2 = cos(T(pi)/T(2) * x2)
        s2 = sin(T(pi)/T(2) * x2)

        dc1 = -T(pi)/T(2) * s1
        ds1 =  T(pi)/T(2) * c1
        dc2 = -T(pi)/T(2) * s2
        ds2 =  T(pi)/T(2) * c2

        # Counters for sets J1, J2, J3
        J1 = 0
        J2 = 0
        J3 = 0
        for j in 3:n
            r = mod(j-1, 3)
            r == 0 ? (J1 += 1) : (r == 1 ? (J2 += 1) : (J3 += 1))
        end

        # Precompute y_j, derivatives and h'(y_j)
        ys      = Vector{T}(undef, n)
        dy1     = Vector{T}(undef, n)  # dy/dx1
        dy2     = Vector{T}(undef, n)  # dy/dx2
        dh      = Vector{T}(undef, n)  # h'(y)
        isJ1    = falses(n)
        isJ2    = falses(n)
        isJ3    = falses(n)

        for j in 3:n
            θ  = T(2)*T(pi)*x1 + T(j)*T(pi)/T(n)
            sθ = sin(θ)
            cθ = cos(θ)

            y = x[j] - T(2)*x2*sθ

            ys[j]  = y
            dy1[j] = -T(4)*T(pi)*x2*cθ
            dy2[j] = -T(2)*sθ

            # h'(y) = 8 y + 8π sin(8π y)
            dh[j] = T(8)*y + T(8)*T(pi)*sin(T(8)*T(pi)*y)

            r = mod(j-1, 3)
            if r == 0
                isJ1[j] = true
            elseif r == 1
                isJ2[j] = true
            else
                isJ3[j] = true
            end
        end

        if ind == 1
            sumx1 = ZERO
            sumx2 = ZERO

            for j in 3:n
                if isJ1[j]
                    # ∂f1/∂x_j
                    g[j] = (T(2) / T(J1)) * dh[j]

                    sumx1 += dh[j] * dy1[j]
                    sumx2 += dh[j] * dy2[j]
                end
            end

            g[1] = dc1*c2 + (T(2) / T(J1)) * sumx1
            g[2] = c1*dc2 + (T(2) / T(J1)) * sumx2

        elseif ind == 2
            sumx1 = ZERO
            sumx2 = ZERO

            for j in 3:n
                if isJ2[j]
                    g[j] = (T(2) / T(J2)) * dh[j]

                    sumx1 += dh[j] * dy1[j]
                    sumx2 += dh[j] * dy2[j]
                end
            end

            g[1] = dc1*s2 + (T(2) / T(J2)) * sumx1
            g[2] = c1*ds2 + (T(2) / T(J2)) * sumx2

        elseif ind == 3
            sumx1 = ZERO
            sumx2 = ZERO

            for j in 3:n
                if isJ3[j]
                    g[j] = (T(2) / T(J3)) * dh[j]

                    sumx1 += dh[j] * dy1[j]
                    sumx2 += dh[j] * dy2[j]
                end
            end

            g[1] = ds1 + (T(2) / T(J3)) * sumx1
            g[2] =          (T(2) / T(J3)) * sumx2
        end






    
    

    

    


    elseif PROBLEM == "AP1"
        if ind == 1
            g .= [(x[1]-1)^3, 2*(x[2]-2)^3]
        elseif ind == 2
            t = 0.5 * exp((x[1]+x[2])/2)
            g .= [t + 2x[1], t + 2x[2]]
        elseif ind == 3
            g .= [-1/6*exp(-x[1]), -1/3*exp(-x[2])]
        end

    elseif PROBLEM == "AP2"
        g .= ind == 1 ? [2x[1]] : [2*(x[1]-1)]

    elseif PROBLEM == "AP3"
        if ind == 1
            g .= [(x[1]-1)^3, 2*(x[2]-2)^3]
        else
            g[1] = -4x[1]*(x[2]-x[1]^2) - 2*(1-x[1])
            g[2] =  2*(x[2]-x[1]^2)
        end

    elseif PROBLEM == "AP4"
        if ind == 1
            g .= [4/9*(x[1]-1)^3, 8/9*(x[2]-2)^3, 12/9*(x[3]-3)^3]
        elseif ind == 2
            t = (1/3)*exp((x[1]+x[2]+x[3])/3)
            g .= [t + 2x[1], t + 2x[2], t + 2x[3]]
        elseif ind == 3
            g .= [-1/4*exp(-x[1]), -1/3*exp(-x[2]), -1/4*exp(-x[3])]
        end

    elseif PROBLEM == "DD1"
        if ind == 1
            g .= 2.0 .* x
        elseif ind == 2
            g[1] = 3
            g[2] = 2
            g[3] = -1 / 3
            g[4] = 3e-2 * (x[4] - x[5])^2
            g[5] = -3e-2 * (x[4] - x[5])^2
        end

    elseif PROBLEM == "DGO1"
        if ind == 1
            g[1] = cos(x[1])
        elseif ind == 2
            g[1] = cos(x[1] + 0.7)
        end

    elseif PROBLEM == "DGO2"
        if ind == 1
            g[1] = 2 * x[1]
        elseif ind == 2
            g[1] = x[1] / sqrt(81 - x[1]^2)
        end

    elseif PROBLEM == "FA1"
        if ind == 1
            g[1] = 4 * exp(-4 * x[1]) / (1 - exp(-4))
        elseif ind == 2
            a = exp(-4 * x[1])
            b = 1 - exp(-4)
            t = (1 - a) / (b * (x[2] + 1))
            g[1] = -2 * a / b * t^(-0.5)
            g[2] = 1 - 0.5 * sqrt(t)
        elseif ind == 3
            a = exp(-4 * x[1])
            b = 1 - exp(-4)
            t = (1 - a) / (b * (x[3] + 1))
            g[1] = -0.4 * t^(-0.9) * a / b
            g[3] = 1 - 0.9 * t^0.1
        end

    elseif PROBLEM == "Far1"
        if ind == 1
            g[1] = 60.0 * (x[1] - 0.1) * exp(15.0 * (-(x[1] - 0.1)^2 - x[2]^2)) +
                   40.0 * (x[1] - 0.6) * exp(20.0 * (-(x[1] - 0.6)^2 - (x[2] - 0.6)^2)) -
                   40.0 * (x[1] + 0.6) * exp(20.0 * (-(x[1] + 0.6)^2 - (x[2] - 0.6)^2)) -
                   40.0 * (x[1] - 0.6) * exp(20.0 * (-(x[1] - 0.6)^2 - (x[2] + 0.6)^2)) -
                   40.0 * (x[1] + 0.6) * exp(20.0 * (-(x[1] + 0.6)^2 - (x[2] + 0.6)^2))

            g[2] = 60.0 * x[2] * exp(15.0 * (-(x[1] - 0.1)^2 - x[2]^2)) +
                   40.0 * (x[2] - 0.6) * exp(20.0 * (-(x[1] - 0.6)^2 - (x[2] - 0.6)^2)) -
                   40.0 * (x[2] - 0.6) * exp(20.0 * (-(x[1] + 0.6)^2 - (x[2] - 0.6)^2)) -
                   40.0 * (x[2] + 0.6) * exp(20.0 * (-(x[1] - 0.6)^2 - (x[2] + 0.6)^2)) -
                   40.0 * (x[2] + 0.6) * exp(20.0 * (-(x[1] + 0.6)^2 - (x[2] + 0.6)^2))

        elseif ind == 2
            g[1] = -80.0 * x[1] * exp(20.0 * (-(x[1]^2 + x[2]^2))) -
                   40.0 * (x[1] - 0.4) * exp(20.0 * (-(x[1] - 0.4)^2 - (x[2] - 0.6)^2)) +
                   40.0 * (x[1] + 0.5) * exp(20.0 * (-(x[1] + 0.5)^2 - (x[2] - 0.7)^2)) +
                   40.0 * (x[1] - 0.5) * exp(20.0 * (-(x[1] - 0.5)^2 - (x[2] + 0.7)^2)) -
                   40.0 * (x[1] + 0.4) * exp(20.0 * (-(x[1] + 0.4)^2 - (x[2] + 0.8)^2))

            g[2] = -80.0 * x[2] * exp(20.0 * (-(x[1]^2 + x[2]^2))) -
                   40.0 * (x[2] - 0.6) * exp(20.0 * (-(x[1] - 0.4)^2 - (x[2] - 0.6)^2)) +
                   40.0 * (x[2] - 0.7) * exp(20.0 * (-(x[1] + 0.5)^2 - (x[2] - 0.7)^2)) +
                   40.0 * (x[2] + 0.7) * exp(20.0 * (-(x[1] - 0.5)^2 - (x[2] + 0.7)^2)) -
                   40.0 * (x[2] + 0.8) * exp(20.0 * (-(x[1] + 0.4)^2 - (x[2] + 0.8)^2))
        end

    elseif PROBLEM == "FDS"
        if ind == 1
            for i in 1:n
                g[i] = 4.0 * i * (x[i] - i)^3 / n^2
            end
        elseif ind == 2
            s = sum(x) / n
            for i in 1:n
                g[i] = exp(s) / n + 2.0 * x[i]
            end
        elseif ind == 3
            for i in 1:n
                g[i] = -i * (n - i + 1.0) * exp(-x[i]) / (n * (n + 1.0))
            end
        end

    elseif PROBLEM == "FF1"
        if ind == 1
            g[1] = 2.0 * (x[1] - 1.0) * exp(-((x[1] - 1.0)^2 + (x[2] + 1.0)^2))
            g[2] = 2.0 * (x[2] + 1.0) * exp(-((x[1] - 1.0)^2 + (x[2] + 1.0)^2))
        elseif ind == 2
            g[1] = 2.0 * (x[1] + 1.0) * exp(-((x[1] + 1.0)^2 + (x[2] - 1.0)^2))
            g[2] = 2.0 * (x[2] - 1.0) * exp(-((x[1] + 1.0)^2 + (x[2] - 1.0)^2))
        end

    elseif PROBLEM == "Hil1"
        a = 2π / 360 * (45.0 + 40.0 * sin(2π * x[1]) + 25.0 * sin(2π * x[2]))
        b = 1.0 + 0.5 * cos(2π * x[1])
        if ind == 1
            g[1] = -160.0 * π^2 / 360.0 * cos(2π * x[1]) * sin(a) * b -
                   π * sin(2π * x[1]) * cos(a)
            g[2] = -100.0 * π^2 / 360.0 * cos(2π * x[2]) * sin(a) * b
        elseif ind == 2
            g[1] = 160.0 * π^2 / 360.0 * cos(2π * x[1]) * cos(a) * b -
                   π * sin(2π * x[1]) * sin(a)
            g[2] = 100.0 * π^2 / 360.0 * cos(2π * x[2]) * cos(a) * b
        end

    elseif PROBLEM == "IKK1"
        if ind == 1
            g[1] = 2.0 * x[1]
            g[2] = 0.0
        elseif ind == 2
            g[1] = 2.0 * (x[1] - 20.0)
            g[2] = 0.0
        elseif ind == 3
            g[1] = 0.0
            g[2] = 2.0 * x[2]
        end

    elseif PROBLEM == "IM1"
        if ind == 1
            g[1] = 1.0 / sqrt(x[1])
            g[2] = 0.0
        elseif ind == 2
            g[1] = 1.0 - x[2]
            g[2] = -x[1]
        end

    elseif PROBLEM == "JOS1"
        if ind == 1
            for i in 1:n
                g[i] = 2.0 * x[i] / n
            end
        elseif ind == 2
            for i in 1:n
                g[i] = 2.0 * (x[i] - 2.0) / n
            end
        end

    elseif PROBLEM == "JOS4"
        if ind == 1
            g[1] = 1.0
            g[2:n] .= 0.0
        elseif ind == 2
            faux = 1.0 + 9.0 * sum(x[2:n]) / (n - 1)
            t = x[1] / faux
            g[1] = -0.25 * t^(-0.75) - 4.0 * t^3
            for i in 2:n
                g[i] = 9.0 / (n - 1) * (1.0 - 0.75 * t^0.25 + 3.0 * t^4)
            end
        end

    elseif PROBLEM == "KW2"
        if ind == 1
            g[1] = 6.0 * (1.0 - x[1]) * exp(-x[1]^2 - (x[2] + 1.0)^2) +
                   6.0 * (1.0 - x[1])^2 * exp(-x[1]^2 - (x[2] + 1.0)^2) * x[1] +
                   10.0 * (1.0 / 5.0 - 3.0 * x[1]^2) * exp(-x[1]^2 - x[2]^2) -
                   20.0 * (x[1] / 5.0 - x[1]^3 - x[2]^5) * exp(-x[1]^2 - x[2]^2) * x[1] -
                   6.0 * exp(-(x[1] + 2.0)^2 - x[2]^2) * (x[1] + 2.0) - 1.0

            g[2] = 6.0 * (1.0 - x[1])^2 * exp(-x[1]^2 - (x[2] + 1.0)^2) * (x[2] + 1.0) -
                   50.0 * x[2]^4 * exp(-x[1]^2 - x[2]^2) -
                   10.0 * (x[1] / 5.0 - x[1]^3 - x[2]^5) * exp(-x[1]^2 - x[2]^2) * 2.0 * x[2] -
                   6.0 * exp(-(x[1] + 2.0)^2 - x[2]^2) * x[2] - 0.5

        elseif ind == 2
            g[1] = -6.0 * (1.0 + x[2])^2 * exp(-x[2]^2 - (1.0 - x[1])^2) * (1.0 - x[1]) +
                   50.0 * x[1]^4 * exp(-x[1]^2 - x[2]^2) -
                   20.0 * (-x[2] / 5.0 + x[2]^3 + x[1]^5) * exp(-x[1]^2 - x[2]^2) * x[1] -
                   6.0 * exp(-(2.0 - x[2])^2 - x[1]^2) * x[1]

            g[2] = -6.0 * (1.0 + x[2]) * exp(-x[2]^2 - (1.0 - x[1])^2) +
                   6.0 * (1.0 + x[2])^2 * exp(-x[2]^2 - (1.0 - x[1])^2) * x[2] +
                   10.0 * (-1.0 / 5.0 + 3.0 * x[2]^2) * exp(-x[1]^2 - x[2]^2) -
                   20.0 * (-x[2] / 5.0 + x[2]^3 + x[1]^5) * exp(-x[1]^2 - x[2]^2) * x[2] +
                   6.0 * exp(-(2.0 - x[2])^2 - x[1]^2) * (2.0 - x[2])
        end

    elseif PROBLEM == "LE1"
        if ind == 1
            t = 0.25 * (x[1]^2 + x[2]^2)^(-0.875)
            g[1] = x[1] * t
            g[2] = x[2] * t
        elseif ind == 2
            t = 0.5 * ((x[1] - 0.5)^2 + (x[2] - 0.5)^2)^(-0.75)
            g[1] = (x[1] - 0.5) * t
            g[2] = (x[2] - 0.5) * t
        end

    elseif PROBLEM == "Lov1"
        if ind == 1
            g[1] = 2.1 * x[1]
            g[2] = 2.0 * 0.98 * x[2]
        elseif ind == 2
            g[1] = 2.0 * 0.99 * (x[1] - 3.0)
            g[2] = 2.0 * 1.03 * (x[2] - 2.5)
        end

    elseif PROBLEM == "Lov2"
        if ind == 1
            g[1] = 0.0
            g[2] = 1.0
        elseif ind == 2
            g[1] = -(-3.0 * x[1]^2 * (x[1] + 1.0) - (x[2] - x[1]^3)) / (x[1] + 1.0)^2
            g[2] = -1.0 / (x[1] + 1.0)
        end

    elseif PROBLEM == "Lov3"
        if ind == 1
            g[1] = 2.0 * x[1]
            g[2] = 2.0 * x[2]
        elseif ind == 2
            g[1] = 2.0 * (x[1] - 6.0)
            g[2] = -2.0 * (x[2] + 0.3)
        end

    elseif PROBLEM == "Lov4"
        if ind == 1
            g[1] = 2.0 * x[1] - 8.0 * ((x[1] + 2.0) * exp(-(x[1] + 2.0)^2 - x[2]^2) +
                                        (x[1] - 2.0) * exp(-(x[1] - 2.0)^2 - x[2]^2))
            g[2] = 2.0 * x[2] - 8.0 * (x[2] * exp(-(x[1] + 2.0)^2 - x[2]^2) +
                                        x[2] * exp(-(x[1] - 2.0)^2 - x[2]^2))
        elseif ind == 2
            g[1] = 2.0 * (x[1] - 6.0)
            g[2] = 2.0 * (x[2] + 0.5)
        end

    elseif PROBLEM == "Lov5"
        M = [
            -1.0   -0.03   0.011;
            -0.03  -1.0    0.07;
             0.011  0.07  -1.01
        ]

        p1 = [x[1], x[2] - 0.15, x[3]]
        a1 = 0.35
        A1 = sqrt(2π / a1) * exp(dot(p1, M * p1) / a1^2)

        p2 = [x[1], x[2] + 1.1, 0.5 * x[3]]
        a2 = 3.0
        A2 = sqrt(2π / a2) * exp(dot(p2, M * p2) / a2^2)

        if ind == 1
            g[1] = sqrt(2)/2 + sqrt(2)/2 * A1 * (2M[1,1]*x[1] + 2M[1,3]*x[3] + 2M[1,2]*(x[2] - 0.15)) / a1^2 +
                    sqrt(2)/2 * A2 * (2M[1,1]*x[1] + M[1,3]*x[3] + 2M[1,2]*(x[2] + 1.1)) / a2^2
            g[1] = -g[1]

            g[2] = sqrt(2)/2 * A1 * (2M[1,2]*x[1] + 2M[2,3]*x[3] + 2M[2,2]*(x[2] - 0.15)) / a1^2 +
                    sqrt(2)/2 * A2 * (2M[1,2]*x[1] + M[2,3]*x[3] + 2M[2,2]*(x[2] + 1.1)) / a2^2
            g[2] = -g[2]

            g[3] = sqrt(2)/2 * A1 * (2M[1,3]*x[1] + 2M[3,3]*x[3] + 2M[2,3]*(x[2] - 0.15)) / a1^2 +
                    sqrt(2)/2 * A2 * (M[1,3]*x[1] + M[3,3]*x[3]/2 + M[2,3]*(x[2] + 1.1)) / a2^2
            g[3] = -g[3]

        elseif ind == 2
            g[1] = -sqrt(2)/2 + sqrt(2)/2 * A1 * (2M[1,1]*x[1] + 2M[1,3]*x[3] + 2M[1,2]*(x[2] - 0.15)) / a1^2 +
                    sqrt(2)/2 * A2 * (2M[1,1]*x[1] + M[1,3]*x[3] + 2M[1,2]*(x[2] + 1.1)) / a2^2
            g[1] = -g[1]

            g[2] = sqrt(2)/2 * A1 * (2M[1,2]*x[1] + 2M[2,3]*x[3] + 2M[2,2]*(x[2] - 0.15)) / a1^2 +
                    sqrt(2)/2 * A2 * (2M[1,2]*x[1] + M[2,3]*x[3] + 2M[2,2]*(x[2] + 1.1)) / a2^2
            g[2] = -g[2]

            g[3] = sqrt(2)/2 * A1 * (2M[1,3]*x[1] + 2M[3,3]*x[3] + 2M[2,3]*(x[2] - 0.15)) / a1^2 +
                    sqrt(2)/2 * A2 * (M[1,3]*x[1] + M[3,3]*x[3]/2 + M[2,3]*(x[2] + 1.1)) / a2^2
            g[3] = -g[3]
        end

    elseif PROBLEM == "Lov6"
        if ind == 1
            g[1] = 1.0
            g[2:6] .= 0.0
        elseif ind == 2
            g[1] = -0.5 / sqrt(x[1]) - sin(10π * x[1]) - 10π * x[1] * cos(10π * x[1])
            for i in 2:6
                g[i] = 2.0 * x[i]
            end
        end

    elseif PROBLEM == "LTDZ"
        if ind == 1
            g[1] = π / 2 * (1 + x[3]) * sin(x[1] * π / 2) * cos(x[2] * π / 2)
            g[2] = π / 2 * (1 + x[3]) * cos(x[1] * π / 2) * sin(x[2] * π / 2)
            g[3] = -cos(x[1] * π / 2) * cos(x[2] * π / 2)
            g .= -g
        elseif ind == 2
            g[1] = π / 2 * (1 + x[3]) * sin(x[1] * π / 2) * sin(x[2] * π / 2)
            g[2] = -π / 2 * (1 + x[3]) * cos(x[1] * π / 2) * cos(x[2] * π / 2)
            g[3] = -cos(x[1] * π / 2) * sin(x[2] * π / 2)
            g .= -g
        elseif ind == 3
            g[1] = π / 2 * (1 + x[3]) * sin(x[1] * π / 2)^2 - π / 2 * (1 + x[3]) * cos(x[1] * π / 2)^2
            g[2] = 0.0
            g[3] = -cos(x[1] * π / 2) * sin(x[1] * π / 2)
            g .= -g
        end

    elseif PROBLEM == "MGH9"
        t = (8.0 - ind) / 2.0
        g[1] = exp(-x[2] * (t - x[3])^2 / 2.0)
        g[2] = -x[1] * exp(-x[2] * (t - x[3])^2 / 2.0) * (t - x[3])^2 / 2.0
        g[3] = x[1] * exp(-x[2] * (t - x[3])^2 / 2.0) * x[2] * (t - x[3])

    elseif PROBLEM == "MGH16"
        t = ind / 5.0
        g[1] = 2.0 * (x[1] + t * x[2] - exp(t))
        g[2] = 2.0 * t * (x[1] + t * x[2] - exp(t))
        g[3] = 2.0 * (x[3] + x[4] * sin(t) - cos(t))
        g[4] = 2.0 * sin(t) * (x[3] + x[4] * sin(t) - cos(t))

    elseif PROBLEM == "MGH26"
        t = 0.0
        for i in 1:n
            t += cos(x[i])
        end
        gaux1 = 2.0 * (n - t + ind * (1.0 - cos(x[ind])) - sin(x[ind]))
        for i in 1:n
            g[i] = gaux1 * sin(x[i])
        end
        g[ind] += gaux1 * (ind * sin(x[ind]) - cos(x[ind]))

    elseif PROBLEM == "MGH33"
        faux = 0.0
        for i in 1:n
            faux += i * x[i]
        end
        faux = 2.0 * (ind * faux - 1.0)
        for i in 1:n
            g[i] = faux * i * ind
        end

    elseif PROBLEM == "MHHM2"
        if ind == 1
            g[1] = 2.0 * (x[1] - 0.8)
            g[2] = 2.0 * (x[2] - 0.6)
        elseif ind == 2
            g[1] = 2.0 * (x[1] - 0.85)
            g[2] = 2.0 * (x[2] - 0.7)
        elseif ind == 3
            g[1] = 2.0 * (x[1] - 0.9)
            g[2] = 2.0 * (x[2] - 0.6)
        end

    elseif PROBLEM == "MLF1"
        if ind == 1
            g[1] = sin(x[1]) / 20.0 + (1.0 + x[1] / 20.0) * cos(x[1])
        elseif ind == 2
            g[1] = cos(x[1]) / 20.0 - (1.0 + x[1] / 20.0) * sin(x[1])
        end

    elseif PROBLEM == "MLF2"
        if ind == 1
            g[1] = (2.0 * x[1] * (x[1]^2 + x[2] - 11.0) + (x[1] + x[2]^2 - 7.0)) / 100.0
            g[2] = ((x[1]^2 + x[2] - 11.0) + 2.0 * x[2] * (x[1] + x[2]^2 - 7.0)) / 100.0
        elseif ind == 2
            g[1] = (8.0 * x[1] * (4.0 * x[1]^2 + 2.0 * x[2] - 11.0) + 2.0 * (2.0 * x[1] + 4.0 * x[2]^2 - 7.0)) / 100.0
            g[2] = (2.0 * (4.0 * x[1]^2 + 2.0 * x[2] - 11.0) + 8.0 * x[2] * (2.0 * x[1] + 4.0 * x[2]^2 - 7.0)) / 100.0
        end

    elseif PROBLEM == "MMR1"
        if ind == 1
            g[1] = 2.0 * x[1]
            g[2] = 0.0
        elseif ind == 2
            g1 = 2.0 - 0.8 * exp(-((x[2] - 0.6) / 0.4)^2) - exp(-((x[2] - 0.2) / 0.04)^2)
            g[1] = -2.0 * x[1] * g1 / (1.0 + x[1]^2)^2
            g[2] = (10.0 * exp(-((x[2] - 0.6) / 0.4)^2) * (x[2] - 0.6) +
                    1250.0 * exp(-((x[2] - 0.2) / 0.04)^2) * (x[2] - 0.2)) / (1.0 + x[1]^2)
        end

    elseif PROBLEM == "MMR3"
        if ind == 1
            g[1] = 3.0 * x[1]^2
            g[2] = 0.0
        elseif ind == 2
            g[1] = -3.0 * (x[2] - x[1])^2
            g[2] = 3.0 * (x[2] - x[1])^2
        end

    elseif PROBLEM == "MMR4"
        if ind == 1
            t = (2.0 * x[1] + x[2] + 2.0 * x[3] + 1.0)^2
            g[1] = 1.0 + 72.0 / t
            g[2] = -2.0 + 36.0 / t
            g[3] = -1.0 + 72.0 / t
        elseif ind == 2
            g[1] = -3.0
            g[2] = 1.0
            g[3] = -1.0
        end

    elseif PROBLEM == "MOP2"
        if ind == 1
            faux = 0.0
            for i in 1:n
                faux += (x[i] - 1.0 / sqrt(n))^2
            end
            for i in 1:n
                g[i] = 2.0 * (x[i] - 1.0 / sqrt(n)) * exp(-faux)
            end
        elseif ind == 2
            faux = 0.0
            for i in 1:n
                faux += (x[i] + 1.0 / sqrt(n))^2
            end
            for i in 1:n
                g[i] = 2.0 * (x[i] + 1.0 / sqrt(n)) * exp(-faux)
            end
        end

    elseif PROBLEM == "MOP3"
        if ind == 1
            A1 = 0.5 * sin(1.0) - 2.0 * cos(1.0) + sin(2.0) - 1.5 * cos(2.0)
            A2 = 1.5 * sin(1.0) - cos(1.0) + 2.0 * sin(2.0) - 0.5 * cos(2.0)
            B1 = 0.5 * sin(x[1]) - 2.0 * cos(x[1]) + sin(x[2]) - 1.5 * cos(x[2])
            B2 = 1.5 * sin(x[1]) - cos(x[1]) + 2.0 * sin(x[2]) - 0.5 * cos(x[2])
            g[1] = 2.0 * (A1 - B1) * (-0.5 * cos(x[1]) - 2.0 * sin(x[1])) +
                   2.0 * (A2 - B2) * (-1.5 * cos(x[1]) - sin(x[1]))
            g[2] = 2.0 * (A1 - B1) * (-cos(x[2]) - 1.5 * sin(x[2])) +
                   2.0 * (A2 - B2) * (-2.0 * cos(x[2]) - 0.5 * sin(x[2]))
        elseif ind == 2
            g[1] = 2.0 * (x[1] + 3.0)
            g[2] = 2.0 * (x[2] + 1.0)
        end

    elseif PROBLEM == "MOP5"
        if ind == 1
            g[1] = x[1] + 2.0 * x[1] * cos(x[1]^2 + x[2]^2)
            g[2] = x[2] + 2.0 * x[2] * cos(x[1]^2 + x[2]^2)
        elseif ind == 2
            g[1] = 3.0 * (3.0 * x[1] - 2.0 * x[2] + 4.0) / 4.0 + 2.0 * (x[1] - x[2] + 1.0) / 27.0
            g[2] = -2.0 * (3.0 * x[1] - 2.0 * x[2] + 4.0) / 4.0 - 2.0 * (x[1] - x[2] + 1.0) / 27.0
        elseif ind == 3
            g[1] = -2.0 * x[1] / (x[1]^2 + x[2]^2 + 1.0)^2 + 2.2 * x[1] * exp(-(x[1]^2 + x[2]^2))
            g[2] = -2.0 * x[2] / (x[1]^2 + x[2]^2 + 1.0)^2 + 2.2 * x[2] * exp(-(x[1]^2 + x[2]^2))
        end
    elseif PROBLEM == "MOP6"
        if ind == 1
            g[1] = 1.0
            g[2] = 0.0
        elseif ind == 2
            a = 1.0 + 10.0 * x[2]
            b = sin(8.0 * π * x[1])
            t = x[1] / a
            g[1] = -2.0 * t - b - 8.0 * π * x[1] * cos(8.0 * π * x[1])
            g[2] = 10.0 * (1.0 - t^2 - t * b) + 10.0 * x[1] / a * (2.0 * t + b)
        end

    elseif PROBLEM == "MOP7"
        if ind == 1
            g[1] = x[1] - 2.0
            g[2] = 2.0 * (x[2] + 1.0) / 13.0
        elseif ind == 2
            g[1] = (x[1] + x[2] - 3.0) / 18.0 - (-x[1] + x[2] + 2.0) / 4.0
            g[2] = (x[1] + x[2] - 3.0) / 18.0 + (-x[1] + x[2] + 2.0) / 4.0
        elseif ind == 3
            g[1] = 2.0 * (x[1] + 2.0 * x[2] - 1.0) / 175.0 - 2.0 * (-x[1] + 2.0 * x[2]) / 17.0
            g[2] = 4.0 * (x[1] + 2.0 * x[2] - 1.0) / 175.0 + 4.0 * (-x[1] + 2.0 * x[2]) / 17.0
        end

    elseif PROBLEM == "PNR"
        if ind == 1
            g[1] = 4.0 * x[1]^3 - 2.0 * x[1] - 10.0 * x[2]
            g[2] = 4.0 * x[2]^3 + 2.0 * x[2] - 10.0 * x[1]
        elseif ind == 2
            g[1] = 2.0 * x[1]
            g[2] = 2.0 * x[2]
        end

    elseif PROBLEM == "QV1"
        if ind == 1
            faux = 0.0
            for i in 1:n
                faux += x[i]^2 - 10.0 * cos(2.0 * π * x[i]) + 10.0
            end
            faux = 0.25 * (faux / n)^(-0.75)
            for i in 1:n
                g[i] = faux * (2.0 * x[i] + 20.0 * π * sin(2.0 * π * x[i])) / n
            end
        elseif ind == 2
            faux = 0.0
            for i in 1:n
                faux += (x[i] - 1.5)^2 - 10.0 * cos(2.0 * π * (x[i] - 1.5)) + 10.0
            end
            faux = 0.25 * (faux / n)^(-0.75)
            for i in 1:n
                g[i] = faux * (2.0 * (x[i] - 1.5) + 20.0 * π * sin(2.0 * π * (x[i] - 1.5))) / n
            end
        end

    elseif PROBLEM == "SD"
        if ind == 1
            g[1] = 2.0
            g[2] = sqrt(2.0)
            g[3] = sqrt(2.0)
            g[4] = 1.0
        elseif ind == 2
            g[1] = -2.0 / x[1]^2
            g[2] = -2.0 * sqrt(2.0) / x[2]^2
            g[3] = -2.0 * sqrt(2.0) / x[3]^2
            g[4] = -2.0 / x[4]^2
        end

    elseif PROBLEM == "SLCDT1"
        if ind == 1
            g[1] = 0.5 * ((x[1] + x[2]) / sqrt(1.0 + (x[1] + x[2])^2) +
                          (x[1] - x[2]) / sqrt(1.0 + (x[1] - x[2])^2) + 1.0) -
                   2.0 * 0.85 * (x[1] + x[2]) * exp(-(x[1] + x[2])^2)
            g[2] = 0.5 * ((x[1] + x[2]) / sqrt(1.0 + (x[1] + x[2])^2) -
                          (x[1] - x[2]) / sqrt(1.0 + (x[1] - x[2])^2) - 1.0) -
                   2.0 * 0.85 * (x[1] + x[2]) * exp(-(x[1] + x[2])^2)
        elseif ind == 2
            g[1] = 0.5 * ((x[1] + x[2]) / sqrt(1.0 + (x[1] + x[2])^2) +
                          (x[1] - x[2]) / sqrt(1.0 + (x[1] - x[2])^2) - 1.0) -
                   2.0 * 0.85 * exp(-(x[1] + x[2])^2) * (x[1] + x[2])
            g[2] = 0.5 * ((x[1] + x[2]) / sqrt(1.0 + (x[1] + x[2])^2) -
                          (x[1] - x[2]) / sqrt(1.0 + (x[1] - x[2])^2) + 1.0) -
                   2.0 * 0.85 * (x[1] + x[2]) * exp(-(x[1] + x[2])^2)
        end

    elseif PROBLEM == "SLCDT2"
        if ind == 1
            g[1] = 4.0 * (x[1] - 1.0)^3
            for i in 2:n
                g[i] = 2.0 * (x[i] - 1.0)
            end
        elseif ind == 2
            g[2] = 4.0 * (x[2] + 1.0)^3
            for i in 1:n
                if i != 2
                    g[i] = 2.0 * (x[i] + 1.0)
                end
            end
        elseif ind == 3
            g[3] = 4.0 * (x[3] - 1.0)^3
            for i in 1:n
                if i != 3
                    g[i] = 2.0 * (x[i] - (-1.0)^(i + 1))
                end
            end
        end

    elseif PROBLEM == "SP1"
        if ind == 1
            g[1] = 2.0 * (x[1] - 1.0) + 2.0 * (x[1] - x[2])
            g[2] = -2.0 * (x[1] - x[2])
        elseif ind == 2
            g[1] = 2.0 * (x[1] - x[2])
            g[2] = 2.0 * (x[2] - 3.0) - 2.0 * (x[1] - x[2])
        end

    elseif PROBLEM == "SSFYY2"
        if ind == 1
            g[1] = 2.0 * x[1] + 5.0 * π * sin(x[1] * π / 2.0)
        elseif ind == 2
            g[1] = 2.0 * (x[1] - 4.0)
        end

    elseif PROBLEM == "SK1"
        if ind == 1
            g[1] = 4.0 * x[1]^3 + 9.0 * x[1]^2 - 20.0 * x[1] - 10.0
        elseif ind == 2
            g[1] = 2.0 * x[1]^3 - 6.0 * x[1]^2 - 20.0 * x[1] + 10.0
        end

    elseif PROBLEM == "SK2"
        if ind == 1
            g[1] = 2.0 * (x[1] - 2.0)
            g[2] = 2.0 * (x[2] + 3.0)
            g[3] = 2.0 * (x[3] - 5.0)
            g[4] = 2.0 * (x[4] - 4.0)
        elseif ind == 2
            faux = 1.0 + (x[1]^2 + x[2]^2 + x[3]^2 + x[4]^2) / 100.0
            s = sin(x[1]) + sin(x[2]) + sin(x[3]) + sin(x[4])
            g[1] = (-cos(x[1]) * faux + s * x[1] / 50.0) / faux^2
            g[2] = (-cos(x[2]) * faux + s * x[2] / 50.0) / faux^2
            g[3] = (-cos(x[3]) * faux + s * x[3] / 50.0) / faux^2
            g[4] = (-cos(x[4]) * faux + s * x[4] / 50.0) / faux^2
        end

    elseif PROBLEM == "TKLY1"
        if ind == 1
            g[1] = 1.0
            g[2] = 0.0
            g[3] = 0.0
            g[4] = 0.0
        elseif ind == 2
            A1 = 2.0 - exp(-((x[2] - 0.1) / 0.004)^2) - 0.8 * exp(-((x[2] - 0.9) / 0.4)^2)
            A2 = 2.0 - exp(-((x[3] - 0.1) / 0.004)^2) - 0.8 * exp(-((x[3] - 0.9) / 0.4)^2)
            A3 = 2.0 - exp(-((x[4] - 0.1) / 0.004)^2) - 0.8 * exp(-((x[4] - 0.9) / 0.4)^2)
            g[1] = -A1 * A2 * A3 / x[1]^2
            g[2] = A2 * A3 / x[1] * (500.0 * exp(-((x[2] - 0.1) / 0.004)^2) * ((x[2] - 0.1) / 0.004) +
                                     4.0 * exp(-((x[2] - 0.9) / 0.4)^2) * ((x[2] - 0.9) / 0.4))
            g[3] = A1 * A3 / x[1] * (500.0 * exp(-((x[3] - 0.1) / 0.004)^2) * ((x[3] - 0.1) / 0.004) +
                                     4.0 * exp(-((x[3] - 0.9) / 0.4)^2) * ((x[3] - 0.9) / 0.4))
            g[4] = A1 * A2 / x[1] * (500.0 * exp(-((x[4] - 0.1) / 0.004)^2) * ((x[4] - 0.1) / 0.004) +
                                     4.0 * exp(-((x[4] - 0.9) / 0.4)^2) * ((x[4] - 0.9) / 0.4))
        end

    elseif PROBLEM == "Toi4"
        if ind == 1
            g[1] = 2.0 * x[1]
            g[2] = 2.0 * x[2]
            g[3] = 0.0
            g[4] = 0.0
        elseif ind == 2
            g[1] = x[1] - x[2]
            g[2] = -(x[1] - x[2])
            g[3] = x[3] - x[4]
            g[4] = -(x[3] - x[4])
        end

    elseif PROBLEM == "Toi8"
        fill!(g, 0.0)
        if ind == 1
            g[1] = 4.0 * (2.0 * x[1] - 1.0)
        elseif ind != 1
            g[ind - 1] = 4.0 * ind * (2.0 * x[ind - 1] - x[ind])
            g[ind] = -2.0 * ind * (2.0 * x[ind - 1] - x[ind])
        end

    elseif PROBLEM == "Toi9"
        fill!(g, 0.0)
        if ind == 1
            g[1] = 4.0 * (2.0 * x[1] - 1.0)
            g[2] = 2.0 * x[2]
        elseif ind > 1 && ind < n
            g[ind - 1] = 4.0 * ind * (2.0 * x[ind - 1] - x[ind]) - 2.0 * (ind - 1) * x[ind - 1]
            g[ind] = -2.0 * ind * (2.0 * x[ind - 1] - x[ind]) + 2.0 * ind * x[ind]
        elseif ind == n
            g[n - 1] = 4.0 * n * (2.0 * x[n - 1] - x[n]) - 2.0 * (n - 1) * x[n - 1]
            g[n] = -2.0 * n * (2.0 * x[n - 1] - x[n])
        end

    elseif PROBLEM == "Toi10"
        fill!(g, 0.0)
        g[ind] = -400.0 * (x[ind + 1] - x[ind]^2) * x[ind]
        g[ind + 1] = 200.0 * (x[ind + 1] - x[ind]^2) + 2.0 * (x[ind + 1] - 1.0)

    elseif PROBLEM == "VU1"
        if ind == 1
            g[1] = -2.0 * x[1] / (x[1]^2 + x[2]^2 + 1.0)^2
            g[2] = -2.0 * x[2] / (x[1]^2 + x[2]^2 + 1.0)^2
        elseif ind == 2
            g[1] = 2.0 * x[1]
            g[2] = 6.0 * x[2]
        end

    elseif PROBLEM == "VU2"
        if ind == 1
            g[1] = 1.0
            g[2] = 1.0
        elseif ind == 2
            g[1] = 2.0 * x[1]
            g[2] = 2.0
        end

    elseif PROBLEM == "ZDT1"
        if ind == 1
            g[1] = 1
        elseif ind == 2
            t = 1 + 9 * sum(x[2:end]) / (n - 1)
            u = x[1] / t
            g[1] = -0.5 * u^(-0.5)
            g[2:end] .= 9 / (n - 1) * (1 - sqrt(u) / 2)
        end

    elseif PROBLEM == "ZDT2"
        if ind == 1
            g[1] = 1
        elseif ind == 2
            t = 1 + 9 * sum(x[2:end]) / (n - 1)
            u = x[1] / t
            g[1] = -2 * u
            g[2:end] .= 9 / (n - 1) * (1 + u^2)
        end

    elseif PROBLEM == "ZDT3"
        if ind == 1
            g[1] = 1
        elseif ind == 2
            t = 1 + 9 * sum(x[2:end]) / (n - 1)
            u = x[1] / t
            g[1] = -0.5 * u^(-0.5) - sin(10π * x[1]) - 10π * x[1] * cos(10π * x[1])
            g[2:end] .= 9 / (n - 1) * (1 - 0.5 * sqrt(u))
        end

    elseif PROBLEM == "ZDT4"
        if ind == 1
            g[1] = 1
        elseif ind == 2
            t = 1 + 10 * (n - 1) + sum(x[2:end].^2 .- 10 * cos.(4π * x[2:end]))
            u = x[1] / t
            g[1] = -0.5 * u^(-0.5)
            for i in 2:n
                g[i] = (2 * x[i] + 40π * sin(4π * x[i])) * (1 - sqrt(u) / 2)
            end
        end

    elseif PROBLEM == "ZDT6"
        if ind == 1
            a = exp(-4 * x[1])
            b = sin(6π * x[1])
            g[1] = 4 * a * b^6 - 36π * a * b^5 * cos(6π * x[1])
        elseif ind == 2
            a = exp(-4 * x[1])
            b = sin(6π * x[1])
            t = 1 - a * b^6
            u = 1 + 9 * (sum(x[2:end])/(n-1))^0.25
            v = t / u
            A1 = 9 * 0.25 * (sum(x[2:end])/(n-1))^(-0.75) / (n - 1)
            g[1] = -2 * v * (4 * a * b^6 - 36π * a * b^5 * cos(6π * x[1]))
            g[2:end] .= A1 * (1 + v^2)
        end

    elseif PROBLEM == "ZLT1"
        g .= 2 * x
        g[ind] += -2 

    else
        error("Unknown problem: $PROBLEM")
    end
end

# ======================================================================
# Hessian ∇²f_i(x)
# ======================================================================
"""
--------------------------------------------------------------------------------
evalh! — Hessian evaluation (in-place)
--------------------------------------------------------------------------------

Computes the Hessian matrix ∇²f_ind(x) of the selected objective function and
stores it in-place in the matrix `H`.

--------------------------------------------------------------------------------
Inputs:

    ind :: Int        → Objective function index
    x   :: Vector{T} → Current point
    n   :: Int        → Number of variables

--------------------------------------------------------------------------------
In-place Output:

    H :: Matrix{T}   → Hessian ∇²f_ind(x)

--------------------------------------------------------------------------------
"""
function evalh!(H::Matrix{T}, ind::Int, x::Vector{T}, n::Int) where {T<:AbstractFloat}
    
    fill!(H, ZERO)

    if PROBLEM == "F1"
        x1 = x[1]
        J1 = 0
        J2 = 0

        # Count J1 and J2
        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        if ind == 1
            # Hessian of (2/J1) * Σ y^2, with y = xj - x1^a
            fac = T(4) / T(J1)  # since (2/J)*2 = 4/J

            for j in 2:n
                if isodd(j)
                    a   = T(0.5) * (ONE + T(3) * T(j - 2) / T(n - 2))
                    xa  = x1^a
                    y   = x[j] - xa

                    du  = a * x1^(a - ONE)                 # d(x1^a)/dx1
                    d2u = a * (a - ONE) * x1^(a - T(2))    # d²(x1^a)/dx1²

                    # ∂²/∂xj²: fac
                    H[j,j] += fac

                    # ∂²/∂x1∂xj = ∂/∂x1 (fac*y) = fac*dy/dx1 = -fac*du
                    H[1,j] += -fac * du
                    H[j,1]  = H[1,j]

                    # ∂²/∂x1² contribution:
                    # d/dx1[-fac*y*du] = fac*(du^2 - y*d2u)
                    H[1,1] += fac * (du^2 - y * d2u)
                end
            end

        elseif ind == 2
            fac = T(4) / T(J2)

            for j in 2:n
                if iseven(j)
                    a   = T(0.5) * (ONE + T(3) * T(j - 2) / T(n - 2))
                    xa  = x1^a
                    y   = x[j] - xa

                    du  = a * x1^(a - ONE)
                    d2u = a * (a - ONE) * x1^(a - T(2))

                    H[j,j] += fac
                    H[1,j] += -fac * du
                    H[j,1]  = H[1,j]

                    H[1,1] += fac * (du^2 - y * d2u)
                end
            end

            # Hessian of -sqrt(x1): d²/dx1² = +1/(4*x1^(3/2))
            H[1,1] += inv(T(4) * x1^(T(3)/T(2)))
        end

    elseif PROBLEM == "F2"

        x1 = x[1]
        J1 = 0
        J2 = 0

        sum11 = ZERO
        sum22 = ZERO

        # Accumulate terms for H[1,1]
        for j in 2:n
            θ = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
            s = sin(θ)
            c = cos(θ)
            y = x[j] - s

            term = c^2 + y*s   # <-- corrected sign

            if isodd(j)
                J1 += 1
                if ind == 1
                    sum11 += term
                end
            else
                J2 += 1
                if ind == 2
                    sum22 += term
                end
            end
        end

        # Second derivative w.r.t. x1
        if ind == 1
            H[1,1] = (144*T(pi)^2 / T(J1)) * sum11
        elseif ind == 2
            H[1,1] = inv(4*x1^(3//2)) + (144*T(pi)^2 / T(J2)) * sum22
        end

        # Mixed and diagonal terms
        for j in 2:n
            θ = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
            c = cos(θ)

            if ind == 1 && isodd(j)
                H[j,j] = 4 / T(J1)

                H[1,j] = -(24*T(pi)/T(J1)) * c
                H[j,1] = H[1,j]

            elseif ind == 2 && iseven(j)
                H[j,j] = 4 / T(J2)

                H[1,j] = -(24*T(pi)/T(J2)) * c
                H[j,1] = H[1,j]
            end
        end

    elseif PROBLEM == "F3"
        x1 = x[1]
        J1 = 0
        J2 = 0

        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        if ind == 1
            fac = T(4) / T(J1)

            for j in 2:n
                θ  = T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)

                if isodd(j)
                    y = x[j] - T(0.8) * x1 * cos(θ)

                    # First derivatives
                    dy1 = -T(0.8) * cos(θ) + T(0.8) * x1 * sin(θ) * T(6) * T(pi)

                    # Second derivative d²y/dx1²
                    d2y1 =
                        T(1.6) * sin(θ) * T(6) * T(pi) +
                        T(0.8) * x1 * cos(θ) * (T(6) * T(pi))^2

                    # ∂²/∂xj²
                    H[j,j] += fac

                    # mixed derivative ∂²/∂x1∂xj
                    H[1,j] += fac * dy1
                    H[j,1]  = H[1,j]

                    # ∂²/∂x1²
                    H[1,1] += fac * (dy1^2 + y * d2y1)
                end
            end

        elseif ind == 2
            fac = T(4) / T(J2)

            for j in 2:n
                θ  = T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)

                if iseven(j)
                    y = x[j] - T(0.8) * x1 * sin(θ)

                    dy1 = -T(0.8) * sin(θ) - T(0.8) * x1 * cos(θ) * T(6) * T(pi)

                    d2y1 =
                        -T(1.6) * cos(θ) * T(6) * T(pi) +
                        T(0.8) * x1 * sin(θ) * (T(6) * T(pi))^2

                    H[j,j] += fac
                    H[1,j] += fac * dy1
                    H[j,1]  = H[1,j]

                    H[1,1] += fac * (dy1^2 + y * d2y1)
                end
            end

            # Hessian of -sqrt(x1)
            H[1,1] += inv(T(4) * x1^(T(3)/T(2)))
        end

    elseif PROBLEM == "F4"
        x1 = x[1]
        J1 = 0
        J2 = 0

        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        if ind == 1
            fac = T(4) / T(J1)

            for j in 2:n
                if isodd(j)
                    θ1 = (T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)) / T(3)
                    y  = x[j] - T(0.8) * x1 * cos(θ1)

                    dy1  = -T(0.8) * cos(θ1) +
                        T(0.8) * x1 * sin(θ1) * (T(6) * T(pi) / T(3))

                    d2y1 =  T(1.6) * sin(θ1) * (T(6) * T(pi) / T(3)) +
                            T(0.8) * x1 * cos(θ1) * (T(6) * T(pi) / T(3))^2

                    H[j,j] += fac
                    H[1,j] += fac * dy1
                    H[j,1]  = H[1,j]

                    H[1,1] += fac * (dy1^2 + y * d2y1)
                end
            end

        elseif ind == 2
            fac = T(4) / T(J2)

            for j in 2:n
                if iseven(j)
                    θ2 = T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)
                    y  = x[j] - T(0.8) * x1 * sin(θ2)

                    dy1  = -T(0.8) * sin(θ2) -
                        T(0.8) * x1 * cos(θ2) * T(6) * T(pi)

                    d2y1 = -T(1.6) * cos(θ2) * T(6) * T(pi) +
                            T(0.8) * x1 * sin(θ2) * (T(6) * T(pi))^2

                    H[j,j] += fac
                    H[1,j] += fac * dy1
                    H[j,1]  = H[1,j]

                    H[1,1] += fac * (dy1^2 + y * d2y1)
                end
            end

            # Hessian of -sqrt(x1)
            H[1,1] += inv(T(4) * x1^(T(3)/T(2)))
        end

    elseif PROBLEM == "F5"

        x1 = x[1]

        # First pass: correct counts of J1 and J2
        J1 = 0
        J2 = 0
        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        sum11 = ZERO
        sum22 = ZERO

        # Second pass: Hessian components
        for j in 2:n
            θ1 = 24*T(pi)*x1 + 4*T(j)*T(pi)/T(n)
            θ2 =  6*T(pi)*x1 +   T(j)*T(pi)/T(n)

            A   = 0.3*x1^2 * cos(θ1) + 0.6*x1
            dA  = 0.6*x1 * cos(θ1) - 7.2*T(pi)*x1^2 * sin(θ1) + 0.6
            d2A = 0.6*cos(θ1) -
                  28.8*T(pi)*x1*sin(θ1) -
                 172.8*T(pi)^2*x1^2*cos(θ1)

            if isodd(j)
                # J1: cosine branch (only affects f1)
                y   = x[j] - A * cos(θ2)
                dy  = -dA * cos(θ2) + 6*T(pi)*A * sin(θ2)
                d2y = -d2A * cos(θ2) +
                       12*T(pi)*dA * sin(θ2) +
                       36*T(pi)^2*A * cos(θ2)

                if ind == 1
                    # Contribution to d²f1/dx1²
                    sum11 += dy^2 + y*d2y

                    # d²f1/dxj²
                    H[j,j] = 4 / T(J1)

                    # d²f1/dx1dxj (symmetric)
                    H[1,j] = (4 / T(J1)) * dy
                    H[j,1] = H[1,j]
                end

            else
                # J2: sine branch (only affects f2)
                y   = x[j] - A * sin(θ2)
                dy  = -dA * sin(θ2) - 6*T(pi)*A * cos(θ2)
                d2y = -d2A * sin(θ2) -
                       12*T(pi)*dA * cos(θ2) +
                       36*T(pi)^2*A * sin(θ2)

                if ind == 2
                    # Contribution to d²f2/dx1²
                    sum22 += dy^2 + y*d2y

                    # d²f2/dxj²
                    H[j,j] = 4 / T(J2)

                    # d²f2/dx1dxj (symmetric)
                    H[1,j] = (4 / T(J2)) * dy
                    H[j,1] = H[1,j]
                end
            end
        end

        # Second derivative with respect to x1
        if ind == 1
            H[1,1] = (4 / T(J1)) * sum11
        elseif ind == 2
            H[1,1] = T(0.25) / (x1 * sqrt(x1)) + (4 / T(J2)) * sum22
        end
    
    elseif PROBLEM == "F6"

        x1 = x[1]
        x2 = x[2]

        c1 = cos(T(pi)/T(2) * x1)
        s1 = sin(T(pi)/T(2) * x1)
        c2 = cos(T(pi)/T(2) * x2)
        s2 = sin(T(pi)/T(2) * x2)

        dc1 = -T(pi)/T(2) * s1
        ds1 =  T(pi)/T(2) * c1
        dc2 = -T(pi)/T(2) * s2
        ds2 =  T(pi)/T(2) * c2

        d2c1 = -T(pi)^2 / T(4) * c1
        d2s1 = -T(pi)^2 / T(4) * s1
        d2c2 = -T(pi)^2 / T(4) * c2
        d2s2 = -T(pi)^2 / T(4) * s2

        # Count J1, J2, J3
        J1 = 0
        J2 = 0
        J3 = 0
        for j in 3:n
            r = mod(j-1, 3)
            r == 0 ? (J1 += 1) : (r == 1 ? (J2 += 1) : (J3 += 1))
        end

        sum11 = ZERO
        sum22 = ZERO
        sum12 = ZERO

        for j in 3:n
            θ  = T(2)*T(pi)*x1 + T(j)*T(pi)/T(n)
            sθ = sin(θ)
            cθ = cos(θ)

            y = x[j] - T(2)*x2*sθ

            # First derivatives
            dy_dx1 = -T(4)*T(pi)*x2*cθ
            dy_dx2 = -T(2)*sθ

            # Second derivatives
            d2y_dx1 =  T(8)*T(pi)^2*x2*sθ
            d2y_dx2 = ZERO
            d2y_dx1x2 = -T(4)*T(pi)*cθ

            r = mod(j-1, 3)

            active =
                (ind == 1 && r == 0) ||
                (ind == 2 && r == 1) ||
                (ind == 3 && r == 2)

            if active
                J = ind == 1 ? J1 : (ind == 2 ? J2 : J3)

                sum11 += T(2) * (dy_dx1^2 + y * d2y_dx1)
                sum22 += T(2) * (dy_dx2^2 + y * d2y_dx2)
                sum12 += T(2) * (dy_dx1 * dy_dx2 + y * d2y_dx1x2)

                # Diagonal block
                H[j,j] = T(4) / T(J)

                # Mixed blocks
                H[1,j] = (T(4) / T(J)) * dy_dx1
                H[j,1] = H[1,j]

                H[2,j] = (T(4) / T(J)) * dy_dx2
                H[j,2] = H[2,j]
            end
        end

        if ind == 1
            H[1,1] = d2c1*c2 + (T(2) / T(J1)) * sum11
            H[2,2] = c1*d2c2 + (T(2) / T(J1)) * sum22
            H[1,2] = dc1*dc2 + (T(2) / T(J1)) * sum12
            H[2,1] = H[1,2]

        elseif ind == 2
            H[1,1] = d2c1*s2 + (T(2) / T(J2)) * sum11
            H[2,2] = c1*d2s2 + (T(2) / T(J2)) * sum22
            H[1,2] = dc1*ds2 + (T(2) / T(J2)) * sum12
            H[2,1] = H[1,2]

        elseif ind == 3
            H[1,1] = d2s1 + (T(2) / T(J3)) * sum11
            H[2,2] = (T(2) / T(J3)) * sum22
            H[1,2] = (T(2) / T(J3)) * sum12
            H[2,1] = H[1,2]
        end
    
    elseif PROBLEM == "F7"
        x1 = x[1]
        J1 = 0
        J2 = 0

        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        if ind == 1
            fac = T(2) / T(J1)

            for j in 2:n
                if isodd(j)
                    a  = T(0.5) * (ONE + T(3) * T(j - 2) / T(n - 2))
                    xa = x1^a
                    y  = x[j] - xa

                    # First derivatives
                    dy1 = -a * x1^(a - ONE)

                    # Second derivative d²y/dx1²
                    d2y1 = -a * (a - ONE) * x1^(a - T(2))

                    # d²φ/dy² = 8 + 64π² cos(8πy)
                    d2φ = T(8) + T(64) * T(pi)^2 * cos(T(8) * T(pi) * y)

                    # dφ/dy
                    dφ = T(8) * y + T(8) * T(pi) * sin(T(8) * T(pi) * y)

                    # ∂²/∂xj²
                    H[j,j] += fac * d2φ

                    # mixed derivative
                    H[1,j] += fac * d2φ * dy1
                    H[j,1]  = H[1,j]

                    # ∂²/∂x1²
                    H[1,1] += fac * (d2φ * dy1^2 + dφ * d2y1)
                end
            end

        elseif ind == 2
            fac = T(2) / T(J2)

            for j in 2:n
                if iseven(j)
                    a  = T(0.5) * (ONE + T(3) * T(j - 2) / T(n - 2))
                    xa = x1^a
                    y  = x[j] - xa

                    dy1  = -a * x1^(a - ONE)
                    d2y1 = -a * (a - ONE) * x1^(a - T(2))

                    dφ  = T(8) * y + T(8) * T(pi) * sin(T(8) * T(pi) * y)
                    d2φ = T(8) + T(64) * T(pi)^2 * cos(T(8) * T(pi) * y)

                    H[j,j] += fac * d2φ
                    H[1,j] += fac * d2φ * dy1
                    H[j,1]  = H[1,j]

                    H[1,1] += fac * (d2φ * dy1^2 + dφ * d2y1)
                end
            end

            # Hessian of -sqrt(x1)
            H[1,1] += inv(T(4) * x1^(T(3)/T(2)))
        end
    
    elseif PROBLEM == "F9"
        x1 = x[1]
        J1 = 0
        J2 = 0

        for j in 2:n
            if isodd(j)
                J1 += 1
            else
                J2 += 1
            end
        end

        if ind == 1
            fac = T(4) / T(J1)

            for j in 2:n
                if isodd(j)
                    θ  = T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)
                    y  = x[j] - sin(θ)

                    # dy/dx1 = -6π cos(θ)
                    dy1 = -T(6) * T(pi) * cos(θ)

                    # d²y/dx1² = 36π² sin(θ)
                    d2y1 = (T(6) * T(pi))^2 * sin(θ)

                    # ∂²/∂xj²
                    H[j,j] += fac

                    # mixed derivative ∂²/∂x1∂xj = fac * dy1
                    H[1,j] += fac * dy1
                    H[j,1]  = H[1,j]

                    # ∂²/∂x1² = fac * (dy1^2 + y * d2y1)
                    H[1,1] += fac * (dy1^2 + y * d2y1)
                end
            end

            return

        elseif ind == 2
            fac = T(4) / T(J2)

            for j in 2:n
                if iseven(j)
                    θ  = T(6) * T(pi) * x1 + T(j) * T(pi) / T(n)
                    y  = x[j] - sin(θ)

                    dy1  = -T(6) * T(pi) * cos(θ)
                    d2y1 = (T(6) * T(pi))^2 * sin(θ)

                    H[j,j] += fac
                    H[1,j] += fac * dy1
                    H[j,1]  = H[1,j]

                    H[1,1] += fac * (dy1^2 + y * d2y1)
                end
            end

            # Hessian of 1 - x1^2 is -2
            H[1,1] += -T(2)

            return
        end


    elseif PROBLEM == "CEC05"

        x1 = x[1]

        # Parameters of the central term
        N   = T(10)
        eps = T(0.1)
        A   = inv(T(2)*N) + eps     # (1/(2N) + eps)

        # Central term second derivative w.r.t. x1
        s     = sin(T(2)*N*T(pi)*x1)
        c2N   = cos(T(2)*N*T(pi)*x1)
        sgn   = sign(s)

        # d/dx1 |sin(2Nπx1)| = sign(sin)*2Nπ*cos(2Nπx1)
        # d2/dx1^2 |sin(2Nπx1)| = sign(sin)*(-(2Nπ)^2*sin(2Nπx1))
        d2_abs = sgn * (-(T(2)*N*T(pi))^2 * s)

        H11_central = A * d2_abs

        # First pass: exact counts of J1 and J2
        J1 = 0
        J2 = 0
        for j in 2:n
            isodd(j) ? (J1 += 1) : (J2 += 1)
        end

        sum11 = ZERO
        sum22 = ZERO

        # Second pass: Hessian contributions
        for j in 2:n
            θ  = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
            sθ = sin(θ)
            cθ = cos(θ)

            y = x[j] - sθ

            # h'(y) and h''(y)
            dhdy  = T(4)*y + T(4)*T(pi)*sin(T(4)*T(pi)*y)
            d2hdy = T(4) + T(16)*T(pi)^2 * cos(T(4)*T(pi)*y)

            # dy/dx1 and d2y/dx1^2
            dy_dx1  = -T(6)*T(pi)*cθ
            d2y_dx1 =  T(36)*T(pi)^2 * sθ

            if isodd(j)
                if ind == 1
                    # Contribution to H[1,1]
                    sum11 += d2hdy * dy_dx1^2 + dhdy * d2y_dx1

                    # Second derivative w.r.t xj
                    H[j,j] = (T(2) / T(J1)) * d2hdy

                    # Mixed derivative d2/dx1dxj
                    H[1,j] = (T(2) / T(J1)) * d2hdy * dy_dx1
                    H[j,1] = H[1,j]
                end
            else
                if ind == 2
                    # Contribution to H[1,1]
                    sum22 += d2hdy * dy_dx1^2 + dhdy * d2y_dx1

                    # Second derivative w.r.t xj
                    H[j,j] = (T(2) / T(J2)) * d2hdy

                    # Mixed derivative d2/dx1dxj
                    H[1,j] = (T(2) / T(J2)) * d2hdy * dy_dx1
                    H[j,1] = H[1,j]
                end
            end
        end

        # Final H[1,1]
        if ind == 1
            H[1,1] = H11_central + (T(2) / T(J1)) * sum11
        elseif ind == 2
            H[1,1] = H11_central + (T(2) / T(J2)) * sum22
        end

    elseif PROBLEM == "CEC07"

        x1 = x[1]

        d2x1p = -T(4)/T(25) * x1^(-T(9)/T(5))   # second derivative of x1^(1/5)

        # Count indices in J1 and J2
        J1 = 0
        J2 = 0
        for j in 2:n
            isodd(j) ? (J1 += 1) : (J2 += 1)
        end

        if ind == 1 && J1 > 0
            sum11 = ZERO

            for j in 2:n
                if isodd(j)
                    θ  = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
                    sθ = sin(θ)
                    cθ = cos(θ)

                    y = x[j] - sθ

                    dy_dx1  = -T(6)*T(pi)*cθ
                    d2y_dx1 =  T(36)*T(pi)^2 * sθ

                    # ∂²(yj²)/∂x1² = 2[(dy/dx1)² + yj d²y/dx1²]
                    d2yj2_dx1 = T(2) * (dy_dx1^2 + y * d2y_dx1)

                    sum11 += d2yj2_dx1

                    # Mixed second derivative H[1,j]
                    H[1,j] = (T(4) / T(J1)) * dy_dx1
                    H[j,1] = H[1,j]

                    # Second derivative w.r.t xj²
                    H[j,j] = T(4) / T(J1)
                end
            end

            H[1,1] = d2x1p + (T(2) / T(J1)) * sum11

        elseif ind == 2 && J2 > 0
            sum11 = ZERO

            for j in 2:n
                if iseven(j)
                    θ  = 6*T(pi)*x1 + T(j)*T(pi)/T(n)
                    sθ = sin(θ)
                    cθ = cos(θ)

                    y = x[j] - sθ

                    dy_dx1  = -T(6)*T(pi)*cθ
                    d2y_dx1 =  T(36)*T(pi)^2 * sθ

                    d2yj2_dx1 = T(2) * (dy_dx1^2 + y * d2y_dx1)

                    sum11 += d2yj2_dx1

                    H[1,j] = (T(4) / T(J2)) * dy_dx1
                    H[j,1] = H[1,j]

                    H[j,j] = T(4) / T(J2)
                end
            end

            H[1,1] = d2x1p + (T(2) / T(J2)) * sum11
        end

    elseif PROBLEM == "CEC09"
        
        x1 = x[1]
        x2 = x[2]

        # epsilon parameter
        eps = T(0.1)

        # Central max term g(x1)
        z   = T(2)*x1 - ONE
        g0  = (ONE + eps) * (ONE - T(4)*z^2)

        # Piecewise derivatives of max{0,g0}
        if g0 > ZERO
            dg  = (ONE + eps) * (-T(16)*z)   # dg/dx1
            d2g = (ONE + eps) * (-T(32))     # d²g/dx1²
        else
            dg  = ZERO
            d2g = ZERO
        end

        # Count J1, J2, J3
        J1 = 0
        J2 = 0
        J3 = 0
        for j in 3:n
            r = mod(j-1, 3)
            r == 0 ? (J1 += 1) : (r == 1 ? (J2 += 1) : (J3 += 1))
        end

        # Common loop will be reused per objective
        if ind == 1 && J1 > 0

            J = T(J1)

            sum11 = ZERO
            sum22 = ZERO
            sum12 = ZERO

            for j in 3:n
                r = mod(j-1, 3)
                r != 0 && continue  # only indices in J1

                θ  = T(2)*T(pi)*x1 + T(j)*T(pi)/T(n)
                sθ = sin(θ)
                cθ = cos(θ)

                y = x[j] - T(2)*x2*sθ

                # First derivatives of y_j
                dy1 = -T(4)*T(pi)*x2*cθ      # ∂y/∂x1
                dy2 = -T(2)*sθ               # ∂y/∂x2

                # Second derivatives of y_j
                d2y1  =  T(8)*T(pi)^2*x2*sθ  # ∂²y/∂x1²
                d2y2  = ZERO                 # ∂²y/∂x2²
                d2y12 = -T(4)*T(pi)*cθ       # ∂²y/∂x1∂x2

                # Contributions to the second derivatives of the sum term
                # F_sum = (2/J) * Σ y^2
                # d²F_sum/dx1²  = (4/J) Σ [ (dy1)^2 + y d2y1 ]
                # d²F_sum/dx2²  = (4/J) Σ [ (dy2)^2 + y d2y2 ]
                # d²F_sum/dx1dx2= (4/J) Σ [ dy1*dy2 + y d2y12 ]
                sum11 += dy1^2 + y * d2y1
                sum22 += dy2^2 + y * d2y2
                sum12 += dy1 * dy2 + y * d2y12

                # Cross derivatives with x_j:
                # ∂²F_sum/∂x1∂xj = (4/J) * dy1
                # ∂²F_sum/∂x2∂xj = (4/J) * dy2
                # ∂²F_sum/∂xj²   = (4/J)
                fac = T(4) / J

                H[j,j] += fac

                H[1,j] += fac * dy1
                H[j,1]  = H[1,j]

                H[2,j] += fac * dy2
                H[j,2]  = H[2,j]
            end

            fac = T(4) / T(J1)

            # Front term of f1: 0.5*(max{0,g0} + 2x1)*x2
            H[1,1] += T(0.5)*d2g*x2 + fac * sum11
            H[2,2] +=                 fac * sum22
            H[1,2] += T(0.5)*(dg + T(2)) + fac * sum12
            H[2,1]  = H[1,2]

        elseif ind == 2 && J2 > 0

            J = T(J2)

            sum11 = ZERO
            sum22 = ZERO
            sum12 = ZERO

            for j in 3:n
                r = mod(j-1, 3)
                r != 1 && continue  # only indices in J2

                θ  = T(2)*T(pi)*x1 + T(j)*T(pi)/T(n)
                sθ = sin(θ)
                cθ = cos(θ)

                y = x[j] - T(2)*x2*sθ

                dy1 = -T(4)*T(pi)*x2*cθ
                dy2 = -T(2)*sθ

                d2y1  =  T(8)*T(pi)^2*x2*sθ
                d2y2  = ZERO
                d2y12 = -T(4)*T(pi)*cθ

                sum11 += dy1^2 + y * d2y1
                sum22 += dy2^2 + y * d2y2
                sum12 += dy1 * dy2 + y * d2y12

                fac = T(4) / J

                H[j,j] += fac

                H[1,j] += fac * dy1
                H[j,1]  = H[1,j]

                H[2,j] += fac * dy2
                H[j,2]  = H[2,j]
            end

            fac = T(4) / T(J2)

            # Front term of f2: 0.5*(max{0,g0} - 2x1 + 2)*x2
            H[1,1] += T(0.5)*d2g*x2 + fac * sum11
            H[2,2] +=                 fac * sum22
            H[1,2] += T(0.5)*(dg - T(2)) + fac * sum12
            H[2,1]  = H[1,2]

        elseif ind == 3 && J3 > 0

            J = T(J3)

            sum11 = ZERO
            sum22 = ZERO
            sum12 = ZERO

            for j in 3:n
                r = mod(j-1, 3)
                r != 2 && continue  # only indices in J3

                θ  = T(2)*T(pi)*x1 + T(j)*T(pi)/T(n)
                sθ = sin(θ)
                cθ = cos(θ)

                y = x[j] - T(2)*x2*sθ

                dy1 = -T(4)*T(pi)*x2*cθ
                dy2 = -T(2)*sθ

                d2y1  =  T(8)*T(pi)^2*x2*sθ
                d2y2  = ZERO
                d2y12 = -T(4)*T(pi)*cθ

                sum11 += dy1^2 + y * d2y1
                sum22 += dy2^2 + y * d2y2
                sum12 += dy1 * dy2 + y * d2y12

                fac = T(4) / J

                H[j,j] += fac

                H[1,j] += fac * dy1
                H[j,1]  = H[1,j]

                H[2,j] += fac * dy2
                H[j,2]  = H[2,j]
            end

            fac = T(4) / T(J3)

            # Front term of f3: 1 - x2  → Hessian = 0
            H[1,1] += fac * sum11
            H[2,2] += fac * sum22
            H[1,2] += fac * sum12
            H[2,1]  = H[1,2]
        end

    elseif PROBLEM == "CEC10"

        x1 = x[1]
        x2 = x[2]

        # Front trigonometric terms
        c1 = cos(T(pi)/T(2) * x1)
        s1 = sin(T(pi)/T(2) * x1)
        c2 = cos(T(pi)/T(2) * x2)
        s2 = sin(T(pi)/T(2) * x2)

        dc1 = -T(pi)/T(2) * s1
        ds1 =  T(pi)/T(2) * c1
        dc2 = -T(pi)/T(2) * s2
        ds2 =  T(pi)/T(2) * c2

        d2c1 = -T(pi)^2 / T(4) * c1
        d2s1 = -T(pi)^2 / T(4) * s1
        d2c2 = -T(pi)^2 / T(4) * c2
        d2s2 = -T(pi)^2 / T(4) * s2

        # Counters
        J1 = 0
        J2 = 0
        J3 = 0
        for j in 3:n
            r = mod(j-1, 3)
            r == 0 ? (J1 += 1) : (r == 1 ? (J2 += 1) : (J3 += 1))
        end

        # Precompute y_j, derivatives, h'(y_j), h''(y_j)
        ys   = Vector{T}(undef, n)
        dy1  = Vector{T}(undef, n)
        dy2  = Vector{T}(undef, n)
        d2y1 = Vector{T}(undef, n)
        d2y2 = Vector{T}(undef, n)
        d2y12 = Vector{T}(undef, n)
        dh   = Vector{T}(undef, n)
        d2h  = Vector{T}(undef, n)
        isJ1 = falses(n)
        isJ2 = falses(n)
        isJ3 = falses(n)

        for j in 3:n
            θ  = T(2)*T(pi)*x1 + T(j)*T(pi)/T(n)
            sθ = sin(θ)
            cθ = cos(θ)

            y = x[j] - T(2)*x2*sθ

            ys[j]   = y
            dy1[j]  = -T(4)*T(pi)*x2*cθ
            dy2[j]  = -T(2)*sθ
            d2y1[j] =  T(8)*T(pi)^2*x2*sθ
            d2y2[j] = ZERO
            d2y12[j]= -T(4)*T(pi)*cθ

            # h'(y) and h''(y)
            dh[j]  = T(8)*y + T(8)*T(pi)*sin(T(8)*T(pi)*y)
            d2h[j] = T(8) + T(64)*T(pi)^2 * cos(T(8)*T(pi)*y)

            r = mod(j-1, 3)
            if r == 0
                isJ1[j] = true
            elseif r == 1
                isJ2[j] = true
            else
                isJ3[j] = true
            end
        end

        sum11 = ZERO
        sum22 = ZERO
        sum12 = ZERO

        if ind == 1 && J1 > 0
            J = T(J1)

            for j in 3:n
                if isJ1[j]
                    # Second derivatives of the sum term
                    sum11 += d2h[j] * dy1[j]^2 + dh[j] * d2y1[j]
                    sum22 += d2h[j] * dy2[j]^2 + dh[j] * d2y2[j]
                    sum12 += d2h[j] * dy1[j]*dy2[j] + dh[j] * d2y12[j]

                    # Blocks involving x_j
                    H[j,j] = (T(2)/J) * d2h[j]
                    H[1,j] = (T(2)/J) * d2h[j] * dy1[j]
                    H[j,1] = H[1,j]
                    H[2,j] = (T(2)/J) * d2h[j] * dy2[j]
                    H[j,2] = H[2,j]
                end
            end

            H[1,1] = d2c1*c2 + (T(2)/J) * sum11
            H[2,2] = c1*d2c2 + (T(2)/J) * sum22
            H[1,2] = dc1*dc2 + (T(2)/J) * sum12
            H[2,1] = H[1,2]

        elseif ind == 2 && J2 > 0
            J = T(J2)

            for j in 3:n
                if isJ2[j]
                    sum11 += d2h[j] * dy1[j]^2 + dh[j] * d2y1[j]
                    sum22 += d2h[j] * dy2[j]^2 + dh[j] * d2y2[j]
                    sum12 += d2h[j] * dy1[j]*dy2[j] + dh[j] * d2y12[j]

                    H[j,j] = (T(2)/J) * d2h[j]
                    H[1,j] = (T(2)/J) * d2h[j] * dy1[j]
                    H[j,1] = H[1,j]
                    H[2,j] = (T(2)/J) * d2h[j] * dy2[j]
                    H[j,2] = H[2,j]
                end
            end

            H[1,1] = d2c1*s2 + (T(2)/J) * sum11
            H[2,2] = c1*d2s2 + (T(2)/J) * sum22
            H[1,2] = dc1*ds2 + (T(2)/J) * sum12
            H[2,1] = H[1,2]

        elseif ind == 3 && J3 > 0
            J = T(J3)

            for j in 3:n
                if isJ3[j]
                    sum11 += d2h[j] * dy1[j]^2 + dh[j] * d2y1[j]
                    sum22 += d2h[j] * dy2[j]^2 + dh[j] * d2y2[j]
                    sum12 += d2h[j] * dy1[j]*dy2[j] + dh[j] * d2y12[j]

                    H[j,j] = (T(2)/J) * d2h[j]
                    H[1,j] = (T(2)/J) * d2h[j] * dy1[j]
                    H[j,1] = H[1,j]
                    H[2,j] = (T(2)/J) * d2h[j] * dy2[j]
                    H[j,2] = H[2,j]
                end
            end

            H[1,1] = d2s1 + (T(2)/J) * sum11
            H[2,2] =          (T(2)/J) * sum22
            H[1,2] =          (T(2)/J) * sum12
            H[2,1] = H[1,2]
        end







    
    
    
    


    elseif PROBLEM == "AP1"
        if ind == 1
            H[1,1] = 3*(x[1]-1)^2
            H[2,2] = 6*(x[2]-2)^2
        elseif ind == 2
            t = 0.25*exp((x[1]+x[2])/2)
            H .= [t+2 t; t t+2]
        elseif ind == 3
            H[1,1] = (1/6)*exp(-x[1])
            H[2,2] = (1/3)*exp(-x[2])
        end

    elseif PROBLEM == "AP2"
        H[1,1] = 2

    elseif PROBLEM == "AP3"
        if ind == 1
            H[1,1] = 3*(x[1]-1)^2
            H[2,2] = 6*(x[2]-2)^2
        else
            H[1,1] = -4*(x[2]-x[1]^2) + 8*x[1]^2 + 2
            H[1,2] = -4*x[1]
            H[2,1] = H[1,2]
            H[2,2] = 2
        end

    elseif PROBLEM == "AP4"
        if ind == 1
            H[1,1] = 12/9*(x[1]-1)^2
            H[2,2] = 24/9*(x[2]-2)^2
            H[3,3] = 36/9*(x[3]-3)^2
        elseif ind == 2
            t = (1/9)*exp((x[1]+x[2]+x[3])/3)
            H .= t
            for i in 1:n
                H[i,i] += 2
            end
        elseif ind == 3
            H[1,1] = (1/4)*exp(-x[1])
            H[2,2] = (1/3)*exp(-x[2])
            H[3,3] = (1/4)*exp(-x[3])
        end
        
    elseif PROBLEM == "DD1"
        if ind == 1
            for i in 1:n
                H[i,i] = 2.0
            end
        else  
            H[4,4] = 6e-2 * (x[4] - x[5])
            H[4,5] = -6e-2 * (x[4] - x[5])
            H[5,4] = H[4,5]
            H[5,5] = 6e-2 * (x[4] - x[5])
        end

    # ----------------------------------------------------------------------
    # DGO1
    elseif PROBLEM == "DGO1"
        if ind == 1
            H[1,1] = -sin(x[1])
        elseif ind == 2
            H[1,1] = -sin(x[1] + 0.7)
        end

    # ----------------------------------------------------------------------
    # DGO2
    elseif PROBLEM == "DGO2"
        if ind == 1
            H[1,1] = 2.0
        elseif ind == 2
            t = sqrt(81.0 - x[1]^2)
            H[1,1] = (t + x[1]^2 / t) / (81.0 - x[1]^2)
        end

    # ----------------------------------------------------------------------
    # FA1
    elseif PROBLEM == "FA1"
        
        if ind == 1
            H[1,1] = -16.0 * exp(-4*x[1]) / (1 - exp(-4))
        elseif ind == 2
            a = exp(-4*x[1]); b = 1 - exp(-4)
            t = (1 - a) / (b * (x[2] + 1))
            H[1,1] = 8*a / b * t^(-0.5) + a / b * t^(-1.5) * (4*a / (b * (x[2] + 1)))
            H[1,2] = -a / b * t^(-0.5) / (x[2] + 1)
            H[2,1] = H[1,2]
            H[2,2] = 0.25 * t^(0.5) / (x[2] + 1)
        elseif ind == 3
            a = exp(-4*x[1]); b = 1 - exp(-4)
            t = (1 - a) / (b * (x[3] + 1))
            H[1,1] = 1.6 * t^(-0.9) * a / b + 0.36 * t^(-1.9) * a / b * (4*a / (b * (x[3] + 1)))
            H[1,3] = -0.36 * t^(-0.9) * a / b / (x[3] + 1)
            H[3,1] = H[1,3]
            H[3,3] = 0.09 * t^(0.1) / (x[3] + 1)
        end

    # ----------------------------------------------------------------------
    # Far1
    elseif PROBLEM == "Far1"
        if ind == 1
            H[1,1] = 60 * exp(15 * ( - (x[1] - 0.1)^2 - x[2]^2 )) +
                    60 * (x[1] - 0.1) * exp(15 * ( - (x[1] - 0.1)^2 - x[2]^2 )) * (-30 * (x[1] - 0.1)) +
                    40 * exp(20 * ( - (x[1] - 0.6)^2 - (x[2] - 0.6)^2 )) +
                    40 * (x[1] - 0.6) * exp(20 * ( - (x[1] - 0.6)^2 - (x[2] - 0.6)^2 )) * (-40 * (x[1] - 0.6)) -
                    40 * exp(20 * ( - (x[1] + 0.6)^2 - (x[2] - 0.6)^2 )) -
                    40 * (x[1] + 0.6) * exp(20 * ( - (x[1] + 0.6)^2 - (x[2] - 0.6)^2 )) * (-40 * (x[1] + 0.6)) -
                    40 * exp(20 * ( - (x[1] - 0.6)^2 - (x[2] + 0.6)^2 )) -
                    40 * (x[1] - 0.6) * exp(20 * ( - (x[1] - 0.6)^2 - (x[2] + 0.6)^2 )) * (-40 * (x[1] - 0.6)) -
                    40 * exp(20 * ( - (x[1] + 0.6)^2 - (x[2] + 0.6)^2 )) -
                    40 * (x[1] + 0.6) * exp(20 * ( - (x[1] + 0.6)^2 - (x[2] + 0.6)^2 )) * (-40 * (x[1] + 0.6))

            H[1,2] = 60 * (x[1] - 0.1) * exp(15 * ( - (x[1] - 0.1)^2 - x[2]^2 )) * (-30 * x[2]) +
                    40 * (x[1] - 0.6) * exp(20 * ( - (x[1] - 0.6)^2 - (x[2] - 0.6)^2 )) * (-40 * (x[2] - 0.6)) -
                    40 * (x[1] + 0.6) * exp(20 * ( - (x[1] + 0.6)^2 - (x[2] - 0.6)^2 )) * (-40 * (x[2] - 0.6)) -
                    40 * (x[1] - 0.6) * exp(20 * ( - (x[1] - 0.6)^2 - (x[2] + 0.6)^2 )) * (-40 * (x[2] + 0.6)) -
                    40 * (x[1] + 0.6) * exp(20 * ( - (x[1] + 0.6)^2 - (x[2] + 0.6)^2 )) * (-40 * (x[2] + 0.6))

            H[2,1] = H[1,2]

            H[2,2] = 60 * exp(15 * ( - (x[1] - 0.1)^2 - x[2]^2 )) +
                    60 * x[2] * exp(15 * ( - (x[1] - 0.1)^2 - x[2]^2 )) * (-30 * x[2]) +
                    40 * exp(20 * ( - (x[1] - 0.6)^2 - (x[2] - 0.6)^2 )) +
                    40 * (x[2] - 0.6) * exp(20 * ( - (x[1] - 0.6)^2 - (x[2] - 0.6)^2 )) * (-40 * (x[2] - 0.6)) -
                    40 * exp(20 * ( - (x[1] + 0.6)^2 - (x[2] - 0.6)^2 )) -
                    40 * (x[2] - 0.6) * exp(20 * ( - (x[1] + 0.6)^2 - (x[2] - 0.6)^2 )) * (-40 * (x[2] - 0.6)) -
                    40 * exp(20 * ( - (x[1] - 0.6)^2 - (x[2] + 0.6)^2 )) -
                    40 * (x[2] + 0.6) * exp(20 * ( - (x[1] - 0.6)^2 - (x[2] + 0.6)^2 )) * (-40 * (x[2] + 0.6)) -
                    40 * exp(20 * ( - (x[1] + 0.6)^2 - (x[2] + 0.6)^2 )) -
                    40 * (x[2] + 0.6) * exp(20 * ( - (x[1] + 0.6)^2 - (x[2] + 0.6)^2 )) * (-40 * (x[2] + 0.6))

        elseif ind == 2
            H[1,1] = -80 * exp(20 * ( -x[1]^2 - x[2]^2 )) -
                    80 * x[1] * exp(20 * ( -x[1]^2 - x[2]^2 )) * (-40 * x[1]) -
                    40 * exp(20 * ( - (x[1] - 0.4)^2 - (x[2] - 0.6)^2 )) -
                    40 * (x[1] - 0.4) * exp(20 * ( - (x[1] - 0.4)^2 - (x[2] - 0.6)^2 )) * (-40 * (x[1] - 0.4)) +
                    40 * exp(20 * ( - (x[1] + 0.5)^2 - (x[2] - 0.7)^2 )) +
                    40 * (x[1] + 0.5) * exp(20 * ( - (x[1] + 0.5)^2 - (x[2] - 0.7)^2 )) * (-40 * (x[1] + 0.5)) +
                    40 * exp(20 * ( - (x[1] - 0.5)^2 - (x[2] + 0.7)^2 )) +
                    40 * (x[1] - 0.5) * exp(20 * ( - (x[1] - 0.5)^2 - (x[2] + 0.7)^2 )) * (-40 * (x[1] - 0.5)) -
                    40 * exp(20 * ( - (x[1] + 0.4)^2 - (x[2] + 0.8)^2 )) -
                    40 * (x[1] + 0.4) * exp(20 * ( - (x[1] + 0.4)^2 - (x[2] + 0.8)^2 )) * (-40 * (x[1] + 0.4))

            H[1,2] = -80 * x[1] * exp(20 * ( -x[1]^2 - x[2]^2 )) * (-40 * x[2]) -
                    40 * (x[1] - 0.4) * exp(20 * ( - (x[1] - 0.4)^2 - (x[2] - 0.6)^2 )) * (-40 * (x[2] - 0.6)) +
                    40 * (x[1] + 0.5) * exp(20 * ( - (x[1] + 0.5)^2 - (x[2] - 0.7)^2 )) * (-40 * (x[2] - 0.7)) +
                    40 * (x[1] - 0.5) * exp(20 * ( - (x[1] - 0.5)^2 - (x[2] + 0.7)^2 )) * (-40 * (x[2] + 0.7)) -
                    40 * (x[1] + 0.4) * exp(20 * ( - (x[1] + 0.4)^2 - (x[2] + 0.8)^2 )) * (-40 * (x[2] + 0.8))

            H[2,1] = H[1,2]

            H[2,2] = -80 * exp(20 * ( -x[1]^2 - x[2]^2 )) -
                    80 * x[2] * exp(20 * ( -x[1]^2 - x[2]^2 )) * (-40 * x[2]) -
                    40 * exp(20 * ( - (x[1] - 0.4)^2 - (x[2] - 0.6)^2 )) -
                    40 * (x[2] - 0.6) * exp(20 * ( - (x[1] - 0.4)^2 - (x[2] - 0.6)^2 )) * (-40 * (x[2] - 0.6)) +
                    40 * exp(20 * ( - (x[1] + 0.5)^2 - (x[2] - 0.7)^2 )) +
                    40 * (x[2] - 0.7) * exp(20 * ( - (x[1] + 0.5)^2 - (x[2] - 0.7)^2 )) * (-40 * (x[2] - 0.7)) +
                    40 * exp(20 * ( - (x[1] - 0.5)^2 - (x[2] + 0.7)^2 )) +
                    40 * (x[2] + 0.7) * exp(20 * ( - (x[1] - 0.5)^2 - (x[2] + 0.7)^2 )) * (-40 * (x[2] + 0.7)) -
                    40 * exp(20 * ( - (x[1] + 0.4)^2 - (x[2] + 0.8)^2 )) -
                    40 * (x[2] + 0.8) * exp(20 * ( - (x[1] + 0.4)^2 - (x[2] + 0.8)^2 )) * (-40 * (x[2] + 0.8))
        end

    # ----------------------------------------------------------------------
    # FDS
    elseif PROBLEM == "FDS"
        
        if ind == 1
            for i in 1:n
                H[i,i] = 12 * i * (x[i] - i)^2 / n^2
            end
        elseif ind == 2
            t = exp(sum(x)/n) / n^2
            H .= t
            for i in 1:n
                H[i,i] += 2.0
            end
        elseif ind == 3
            for i in 1:n
                H[i,i] = i * (n - i + 1) * exp(-x[i]) / (n * (n + 1))
            end
        end

    # ----------------------------------------------------------------------
    # FF1
    elseif PROBLEM == "FF1"
        
        if ind == 1
            H[1,1] = 2 * exp(-((x[1]-1)^2 + (x[2]+1)^2)) + 2 * (x[1]-1) * exp(-((x[1]-1)^2 + (x[2]+1)^2)) * (-2 * (x[1]-1))
            H[1,2] = 2 * (x[1]-1) * exp(-((x[1]-1)^2 + (x[2]+1)^2)) * (-2 * (x[2]+1))
            H[2,1] = H[1,2]
            H[2,2] = 2 * exp(-((x[1]-1)^2 + (x[2]+1)^2)) + 2 * (x[2]+1) * exp(-((x[1]-1)^2 + (x[2]+1)^2)) * (-2 * (x[2]+1))
        elseif ind == 2
            H[1,1] = 2 * exp(-((x[1]+1)^2 + (x[2]-1)^2)) + 2 * (x[1]+1) * exp(-((x[1]+1)^2 + (x[2]-1)^2)) * (-2 * (x[1]+1))
            H[1,2] = 2 * (x[1]+1) * exp(-((x[1]+1)^2 + (x[2]-1)^2)) * (-2 * (x[2]-1))
            H[2,1] = H[1,2]
            H[2,2] = 2 * exp(-((x[1]+1)^2 + (x[2]-1)^2)) + 2 * (x[2]-1) * exp(-((x[1]+1)^2 + (x[2]-1)^2)) * (-2 * (x[2]-1))
        end

    # ----------------------------------------------------------------------
    # Hil1
    elseif PROBLEM == "Hil1"
        a = 2π / 360 * (45 + 40 * sin(2π * x[1]) + 25 * sin(2π * x[2]))
        b = 1 + 0.5 * cos(2π * x[1])

        if ind == 1
            A1 = 160 / 360 * π^2 * cos(2π * x[1])
            A2 = 100 / 360 * π^2 * cos(2π * x[2])
            A3 = -2π * sin(2π * x[1]) * sin(a) + cos(2π * x[1]) * cos(a) * A1

            H[1,1] = -160 * π^2 / 360 * b * A3 -
                    160 * π^2 / 360 * cos(2π * x[1]) * sin(a) * (-π * sin(2π * x[1])) -
                    2π^2 * cos(2π * x[1]) * cos(a) +
                    π * sin(2π * x[1]) * sin(a) * A1

            H[1,2] = -160 * π^2 / 360 * cos(2π * x[1]) * b * cos(a) * A2 +
                    π * sin(2π * x[1]) * sin(a) * A2

            H[2,1] = H[1,2]

            H[2,2] = 200 * π^3 / 360 * b * sin(2π * x[2]) * sin(a) -
                    100 * π^2 / 360 * b * cos(2π * x[2]) * cos(a) * A2

        elseif ind == 2
            A1 = 160 / 360 * π^2 * cos(2π * x[1])
            A2 = 100 / 360 * π^2 * cos(2π * x[2])
            A3 = -2π * sin(2π * x[1]) * cos(a) - cos(2π * x[1]) * sin(a) * A1

            H[1,1] = 160 * π^2 / 360 * b * A3 +
                    160 * π^2 / 360 * cos(2π * x[1]) * cos(a) * (-π * sin(2π * x[1])) -
                    2π^2 * cos(2π * x[1]) * sin(a) -
                    π * sin(2π * x[1]) * cos(a) * A1

            H[1,2] = -160 * π^2 / 360 * cos(2π * x[1]) * b * sin(a) * A2 -
                    π * sin(2π * x[1]) * cos(a) * A2

            H[2,1] = H[1,2]

            H[2,2] = -200 * π^3 / 360 * b * sin(2π * x[2]) * cos(a) -
                    100 * π^2 / 360 * b * cos(2π * x[2]) * sin(a) * A2
        end
        
    # ----------------------------------------------------------------------
    # IKK1
    elseif PROBLEM == "IKK1"
        
        if ind == 1
            H[1,1] = 2
        elseif ind == 2
            H[1,1] = 2
        elseif ind == 3
            H[2,2] = 2
        end

    # ----------------------------------------------------------------------
    # IM1
    elseif PROBLEM == "IM1"
        
        if ind == 1
            H[1,1] = -0.5 / sqrt(x[1]^3)
        elseif ind == 2
            H[1,2] = -1
            H[2,1] = -1
        end

    # ----------------------------------------------------------------------
    # JOS1
    elseif PROBLEM == "JOS1"
        
        for i in 1:n
            H[i,i] = 2.0 / n
        end

    # ----------------------------------------------------------------------
    # JOS4
    elseif PROBLEM == "JOS4"
        if ind == 1
            H .= 0.0
        elseif ind == 2
            a = 1.0 + 9.0 * sum(x[2:n]) / (n - 1)
            t = x[1] / a
            c = -x[1] * 9.0 / (n - 1) / a^2

            H[1, 1] = (0.1875 * t^(-1.75) - 12.0 * t^2) / a

            for j in 2:n
                H[1, j] = (0.1875 * t^(-1.75) - 12.0 * t^2) * c
            end

            b = 9.0 / (n - 1) * (-0.1875 * t^(-0.75) + 12.0 * t^3) * c
            for i in 2:n
                for j in i:n
                    H[i, j] = b
                end
            end

            for i in 2:n
                for j in 1:i-1
                    H[i, j] = H[j, i]
                end
            end
        end

    # ----------------------------------------------------------------------
    # KW2
    elseif PROBLEM == "KW2"
        if ind == 1
            a = exp(-x[1]^2 - (x[2] + 1.0)^2)
            b = exp(-x[1]^2 - x[2]^2)
            c = exp(-(x[1] + 2.0)^2 - x[2]^2)

            H[1,1] = -6.0 * a - 12.0 * x[1] * (1.0 - x[1]) * a +
                      6.0 * (3.0 * x[1]^2 - 4.0 * x[1] + 1.0) * a -
                      12.0 * x[1]^2 * (1.0 - x[1])^2 * a +
                      10.0 * (-6.0 * x[1]) * b -
                      20.0 * x[1] * (1.0 / 5.0 - 3.0 * x[1]^2) * b -
                      20.0 * (2.0 / 5.0 * x[1] - 4.0 * x[1]^3 - x[2]^5) * b +
                      40.0 * x[1]^2 * (x[1] / 5.0 - x[1]^3 - x[2]^5) * b -
                      6.0 * c + 12.0 * (x[1] + 2.0)^2 * exp(-(x[1] + 2.0)^2 - x[2]^2)

            H[1,2] = 6.0 * (1.0 - x[1]) * a * (-2.0 * (x[2] + 1.0)) +
                      6.0 * x[1] * (1.0 - x[1])^2 * a * (-2.0 * (x[2] + 1.0)) +
                      10.0 * (1.0 / 5.0 - 3.0 * x[1]^2) * b * (-2.0 * x[2]) -
                      20.0 * x[1] * (-5.0 * x[2]^4) * b -
                      20.0 * x[1] * (x[1] / 5.0 - x[1]^3 - x[2]^5) * b * (-2.0 * x[2]) -
                      6.0 * (x[1] + 2.0) * c * (-2.0 * x[2])

            H[2,1] = H[1,2]

            H[2,2] = 6.0 * (1.0 - x[1])^2 * a +
                      6.0 * (1.0 - x[1])^2 * a * (x[2] + 1.0) * (-2.0 * (x[2] + 1.0)) -
                      50.0 * 4.0 * x[2]^3 * b -
                      50.0 * x[2]^4 * b * (-2.0 * x[2]) -
                      20.0 * (x[1] / 5.0 - x[1]^3 - 6.0 * x[2]^5) * b -
                      20.0 * x[2] * (x[1] / 5.0 - x[1]^3 - x[2]^5) * b * (-2.0 * x[2]) -
                      6.0 * c - 6.0 * c * x[2] * (-2.0 * x[2])

        elseif ind == 2
            a = exp(-x[2]^2 - (1.0 - x[1])^2)
            b = exp(-x[1]^2 - x[2]^2)
            c = exp(-(2.0 - x[2])^2 - x[1]^2)

            H[1,1] = 6.0 * (1.0 + x[2])^2 * a -
                      6.0 * (1.0 + x[2])^2 * a * (1.0 - x[1]) * (2.0 * (1.0 - x[1])) +
                      50.0 * 4.0 * x[1]^3 * b +
                      50.0 * x[1]^4 * b * (-2.0 * x[1]) -
                      20.0 * (-x[2] / 5.0 + x[2]^3 + 6.0 * x[1]^5) * b -
                      20.0 * x[1] * (-x[2] / 5.0 + x[2]^3 + x[1]^5) * b * (-2.0 * x[1]) -
                      6.0 * c - 6.0 * c * x[1] * (-2.0 * x[1])

            H[1,2] = -12.0 * (1.0 + x[2]) * a * (1.0 - x[1]) -
                      6.0 * (1.0 + x[2])^2 * a * (1.0 - x[1]) * (-2.0 * x[2]) +
                      50.0 * x[1]^4 * b * (-2.0 * x[2]) -
                      20.0 * (-1.0 / 5.0 + 3.0 * x[2]^2) * b * x[1] -
                      20.0 * (-x[2] / 5.0 + x[2]^3 + x[1]^5) * b * x[1] * (-2.0 * x[2]) -
                      6.0 * c * x[1] * (2.0 * (2.0 - x[2]))

            H[2,1] = H[1,2]

            H[2,2] = -6.0 * a -
                      6.0 * (1.0 + x[2]) * a * (-2.0 * x[2]) +
                      6.0 * (1.0 + 4.0 * x[2] + 3.0 * x[2]^2) * a +
                      6.0 * x[2] * (1.0 + x[2])^2 * a * (-2.0 * x[2]) +
                      10.0 * 6.0 * x[2] * b +
                      10.0 * (-1.0 / 5.0 + 3.0 * x[2]^2) * b * (-2.0 * x[2]) -
                      20.0 * (-2.0 / 5.0 * x[2] + 4.0 * x[2]^3 + x[1]^5) * b -
                      20.0 * x[2] * (-x[2] / 5.0 + x[2]^3 + x[1]^5) * b * (-2.0 * x[2]) -
                      6.0 * c + 6.0 * c * (2.0 - x[2]) * (2.0 * (2.0 - x[2]))
        end

    # ----------------------------------------------------------------------
    # LE1
    elseif PROBLEM == "LE1"
        if ind == 1
            t = 0.25 * (x[1]^2 + x[2]^2)^(-0.875)
            a = 0.5 * (-0.875) * (x[1]^2 + x[2]^2)^(-1.875)

            H[1,1] = t + a * x[1]^2
            H[1,2] = a * x[1] * x[2]
            H[2,1] = H[1,2]
            H[2,2] = t + a * x[2]^2

        elseif ind == 2
            t = 0.5 * ((x[1] - 0.5)^2 + (x[2] - 0.5)^2)^(-0.75)
            a = (-0.75) * ((x[1] - 0.5)^2 + (x[2] - 0.5)^2)^(-1.75)

            H[1,1] = t + a * (x[1] - 0.5)^2
            H[1,2] = (x[1] - 0.5) * a * (x[2] - 0.5)
            H[2,1] = H[1,2]
            H[2,2] = t + a * (x[2] - 0.5)^2
        end

    # ----------------------------------------------------------------------
    # Lov1
    elseif PROBLEM == "Lov1"
        if ind == 1
            H[1,1] = 2.1
            H[1,2] = 0.0
            H[2,1] = 0.0
            H[2,2] = 2.0 * 0.98
        elseif ind == 2
            H[1,1] = 2.0 * 0.99
            H[1,2] = 0.0
            H[2,1] = 0.0
            H[2,2] = 2.0 * 1.03
        end

    # ----------------------------------------------------------------------
    # Lov2
    elseif PROBLEM == "Lov2"
        if ind == 1
            H[1,1] = 0.0
            H[1,2] = 0.0
            H[2,1] = 0.0
            H[2,2] = 0.0

        elseif ind == 2
            H[1,1] = (6 * x[1]^2 + 6 * x[1]) * (x[1] + 1)^2 +
                    (-3 * x[1]^2 * (x[1] + 1) - (x[2] - x[1]^3)) * 2 * (x[1] + 1)
            H[1,1] /= (x[1] + 1)^4

            H[1,2] = 1 / (x[1] + 1)^2
            H[2,1] = H[1,2]
            H[2,2] = 0.0
        end

    # ----------------------------------------------------------------------
    # Lov3
    elseif PROBLEM == "Lov3"
        if ind == 1
            H[1,1] = 2.0
            H[1,2] = 0.0
            H[2,1] = 0.0
            H[2,2] = 2.0
        elseif ind == 2
            H[1,1] = 2.0
            H[1,2] = 0.0
            H[2,1] = 0.0
            H[2,2] = -2.0
        end

    # ----------------------------------------------------------------------
    # Lov4
    elseif PROBLEM == "Lov4"
        if ind == 1
            H[1,1] = 2.0 -
                    8.0 * exp(-(x[1] + 2)^2 - x[2]^2) -
                    8.0 * (x[1] + 2) * exp(-(x[1] + 2)^2 - x[2]^2) * (-2 * (x[1] + 2)) -
                    8.0 * exp(-(x[1] - 2)^2 - x[2]^2) -
                    8.0 * (x[1] - 2) * exp(-(x[1] - 2)^2 - x[2]^2) * (-2 * (x[1] - 2))

            H[1,2] = -8.0 * (x[1] + 2) * exp(-(x[1] + 2)^2 - x[2]^2) * (-2 * x[2]) -
                    8.0 * (x[1] - 2) * exp(-(x[1] - 2)^2 - x[2]^2) * (-2 * x[2])

            H[2,1] = H[1,2]

            H[2,2] = 2.0 -
                    8.0 * exp(-(x[1] + 2)^2 - x[2]^2) -
                    8.0 * x[2] * exp(-(x[1] + 2)^2 - x[2]^2) * (-2 * x[2]) -
                    8.0 * exp(-(x[1] - 2)^2 - x[2]^2) -
                    8.0 * x[2] * exp(-(x[1] - 2)^2 - x[2]^2) * (-2 * x[2])

        elseif ind == 2
            H[1,1] = 2.0
            H[1,2] = 0.0
            H[2,1] = 0.0
            H[2,2] = 2.0
        end

    # ----------------------------------------------------------------------
    # Lov5
    elseif PROBLEM == "Lov5"
        M = [
            -1.0   -0.03   0.011;
            -0.03  -1.0    0.07;
            0.011  0.07  -1.01
        ]

        p = [x[1], x[2] - 0.15, x[3]]
        a = 0.35
        A1 = sqrt(2π / a) * exp(dot(p, M * p) / a^2)

        p = [x[1], x[2] + 1.1, 0.5 * x[3]]
        b = 3.0
        A2 = sqrt(2π / b) * exp(dot(p, M * p) / b^2)

        H[1,1] = sqrt(2.0) * A1 * M[1,1] / a^2 +
                sqrt(2.0)/2 * (2*M[1,1]*x[1] + 2*M[1,3]*x[3] + 2*M[1,2]*(x[2]-0.15)) / a^2 *
                A1 * (2*M[1,1]*x[1] + 2*M[1,3]*x[3] + 2*M[1,2]*(x[2]-0.15)) / a^2 +
                sqrt(2.0) * A2 * M[1,1] / b^2 +
                sqrt(2.0)/2 * (2*M[1,1]*x[1] + M[1,3]*x[3] + 2*M[1,2]*(x[2]+1.1)) / b^2 *
                A2 * (2*M[1,1]*x[1] + M[1,3]*x[3] + 2*M[1,2]*(x[2]+1.1)) / b^2

        H[1,2] = sqrt(2.0) * A1 * M[1,2] / a^2 +
                sqrt(2.0)/2 * (2*M[1,1]*x[1] + 2*M[1,3]*x[3] + 2*M[1,2]*(x[2]-0.15)) / a^2 *
                A1 * (2*M[1,2]*x[1] + 2*M[2,3]*x[3] + 2*M[2,2]*(x[2]-0.15)) / a^2 +
                sqrt(2.0) * A2 * M[1,2] / b^2 +
                sqrt(2.0)/2 * (2*M[1,1]*x[1] + M[1,3]*x[3] + 2*M[1,2]*(x[2]+1.1)) / b^2 *
                A2 * (2*M[1,2]*x[1] + M[2,3]*x[3] + 2*M[2,2]*(x[2]+1.1)) / b^2

        H[1,3] = sqrt(2.0) * A1 * M[1,3] / a^2 +
                sqrt(2.0)/2 * (2*M[1,1]*x[1] + 2*M[1,3]*x[3] + 2*M[1,2]*(x[2]-0.15)) / a^2 *
                A1 * (2*M[1,3]*x[1] + 2*M[3,3]*x[3] + 2*M[2,3]*(x[2]-0.15)) / a^2 +
                sqrt(2.0)/2 * A2 * M[1,3] / b^2 +
                sqrt(2.0)/2 * (2*M[1,1]*x[1] + M[1,3]*x[3] + 2*M[1,2]*(x[2]+1.1)) / b^2 *
                A2 * (M[1,3]*x[1] + (M[3,3]*x[3])/2 + M[2,3]*(x[2]+1.1)) / b^2

        H[2,2] = sqrt(2.0) * A1 * M[2,3] / a^2 +
                sqrt(2.0)/2 * (2*M[1,3]*x[1] + 2*M[3,3]*x[3] + 2*M[2,3]*(x[2]-0.15)) / a^2 *
                A1 * (2*M[1,2]*x[1] + 2*M[2,3]*x[3] + 2*M[2,2]*(x[2]-0.15)) / a^2 +
                sqrt(2.0) * A2 * M[2,2] / b^2 +
                sqrt(2.0)/2 * (2*M[1,2]*x[1] + M[2,3]*x[3] + 2*M[2,2]*(x[2]+1.1)) / b^2 *
                A2 * (2*M[1,2]*x[1] + M[2,3]*x[3] + 2*M[2,2]*(x[2]+1.1)) / b^2

        H[2,3] = sqrt(2.0) * A1 * M[2,3] / a^2 +
                sqrt(2.0)/2 * (2*M[1,2]*x[1] + 2*M[2,3]*x[3] + 2*M[2,2]*(x[2]-0.15)) / a^2 *
                A1 * (2*M[1,3]*x[1] + 2*M[3,3]*x[3] + 2*M[2,3]*(x[2]-0.15)) / a^2 +
                sqrt(2.0)/2 * A2 * M[2,3] / b^2 +
                sqrt(2.0)/2 * (2*M[1,2]*x[1] + M[2,3]*x[3] + 2*M[2,2]*(x[2]+1.1)) / b^2 *
                A2 * (M[1,3]*x[1] + (M[3,3]*x[3])/2 + M[2,3]*(x[2]+1.1)) / b^2

        H[3,3] = sqrt(2.0) * A1 * M[3,3] / a^2 +
                sqrt(2.0)/2 * (2*M[1,3]*x[1] + 2*M[3,3]*x[3] + 2*M[2,3]*(x[2]-0.15)) / a^2 *
                A1 * (2*M[1,3]*x[1] + 2*M[3,3]*x[3] + 2*M[2,3]*(x[2]-0.15)) / a^2 +
                sqrt(2.0)/2 * A2 * M[3,3] / (2 * b^2) +
                sqrt(2.0)/2 * (M[1,3]*x[1] + M[3,3]*x[3]/2 + M[2,3]*(x[2]+1.1)) / b^2 *
                A2 * (M[1,3]*x[1] + (M[3,3]*x[3])/2 + M[2,3]*(x[2]+1.1)) / b^2

        H[2,1] = H[1,2]
        H[3,1] = H[1,3]
        H[3,2] = H[2,3]

        H .= -H

    # ----------------------------------------------------------------------
    # Lov6
    elseif PROBLEM == "Lov6"
        if ind == 1
            H .= 0.0
        elseif ind == 2
            H .= 0.0
            H[1,1] = 0.25 / sqrt(x[1]^3) -
                    10π * cos(10π * x[1]) -
                    10π * cos(10π * x[1]) +
                    100π^2 * x[1] * sin(10π * x[1])
            for i in 2:6
                H[i,i] = 2.0
            end
        end

    # ----------------------------------------------------------------------
    # LTDZ  — Combining convergence and diversity in evolutionary multiobjective optimization
    elseif PROBLEM == "LTDZ"
        if ind == 1
            H[1,1] = (π/2) * (1 + x[3]) * cos(x[1]*π/2) * cos(x[2]*π/2) * (π/2)
            H[1,2] = (π/2) * (1 + x[3]) * sin(x[1]*π/2) * sin(x[2]*π/2) * (-π/2)
            H[1,3] = (π/2) * sin(x[1]*π/2) * cos(x[2]*π/2)

            H[2,1] = H[1,2]
            H[2,2] = (π/2) * (1 + x[3]) * cos(x[1]*π/2) * cos(x[2]*π/2) * (π/2)
            H[2,3] = (π/2) * cos(x[1]*π/2) * sin(x[2]*π/2)

            H[3,1] = H[1,3]
            H[3,2] = H[2,3]
            H[3,3] = 0.0

            H .= -H

        elseif ind == 2
            H[1,1] = (π/2) * (1 + x[3]) * cos(x[1]*π/2) * sin(x[2]*π/2) * (π/2)
            H[1,2] = (π/2) * (1 + x[3]) * sin(x[1]*π/2) * cos(x[2]*π/2) * (π/2)
            H[1,3] = (π/2) * sin(x[1]*π/2) * sin(x[2]*π/2)

            H[2,1] = H[1,2]
            H[2,2] = -(π/2) * (1 + x[3]) * cos(x[1]*π/2) * sin(x[2]*π/2) * (-π/2)
            H[2,3] = -(π/2) * cos(x[1]*π/2) * cos(x[2]*π/2)

            H[3,1] = H[1,3]
            H[3,2] = H[2,3]
            H[3,3] = 0.0

            H .= -H

        elseif ind == 3
            H[1,1] = π * (1 + x[3]) * sin(x[1]*π/2) * cos(x[1]*π/2) * (π/2) -
                    π * (1 + x[3]) * cos(x[1]*π/2) * sin(x[1]*π/2) * (-π/2)
            H[1,2] = 0.0
            H[1,3] = (π/2) * sin(x[1]*π/2)^2 - (π/2) * cos(x[1]*π/2)^2

            H[2,1] = H[1,2]
            H[2,2] = 0.0
            H[2,3] = 0.0

            H[3,1] = H[1,3]
            H[3,2] = H[2,3]
            H[3,3] = 0.0

            H .= -H
        end

        # ----------------------------------------------------------------------
    # MGH9
    elseif PROBLEM == "MGH9"
        t = (8.0 - ind) / 2.0
        a = exp(-x[2] * (t - x[3])^2 / 2.0)

        H[1,1] = 0.0
        H[1,2] = a * (-(t - x[3])^2 / 2.0)
        H[1,3] = a * (x[2] * (t - x[3]))

        H[2,1] = H[1,2]
        H[2,2] = -x[1] * a * (-(t - x[3])^2 / 2.0) * (t - x[3])^2 / 2.0
        H[2,3] = -x[1] * a * (x[2] * (t - x[3])) * (t - x[3])^2 / 2.0 +
                x[1] * a * (t - x[3])

        H[3,1] = H[1,3]
        H[3,2] = H[2,3]
        H[3,3] = x[1] * a * (x[2] * (t - x[3])) * x[2] * (t - x[3]) - x[1] * a * x[2]

    # ----------------------------------------------------------------------
    # MGH16
    elseif PROBLEM == "MGH16"
        t = ind / 5.0

        H[1,1] = 2.0
        H[1,2] = 2.0 * t
        H[2,1] = H[1,2]
        H[2,2] = 2.0 * t^2
        H[3,3] = 2.0
        H[3,4] = 2.0 * sin(t)
        H[4,3] = H[3,4]
        H[4,4] = 2.0 * sin(t)^2

    # ----------------------------------------------------------------------
    # MGH26
    elseif PROBLEM == "MGH26"
        t = sum(cos.(x))
        a = 2.0 * (length(x) - t + ind * (1.0 - cos(x[ind])) - sin(x[ind]))

        for i in 1:length(x)
            if i == ind
                for j in i:length(x)
                    if j == i
                        H[i,j] = a * (cos(x[ind]) + ind * cos(x[ind]) + sin(x[ind])) +
                                2.0 * (sin(x[ind]) + ind * sin(x[ind]) - cos(x[ind]))^2
                    else
                        H[i,j] = 2.0 * sin(x[j]) * (sin(x[ind]) + ind * sin(x[ind]) - cos(x[ind]))
                    end
                end
            else
                for j in i:length(x)
                    if j == i
                        H[i,j] = a * cos(x[j]) + 2.0 * sin(x[j])^2
                    elseif j == ind
                        H[i,j] = 2.0 * (sin(x[j]) + ind * sin(x[j]) - cos(x[j])) * sin(x[i])
                    else
                        H[i,j] = 2.0 * sin(x[j]) * sin(x[i])
                    end
                end
            end
        end

        for i in 2:length(x)
            for j in 1:(i-1)
                H[i,j] = H[j,i]
            end
        end

    # ----------------------------------------------------------------------
    # MGH33
    elseif PROBLEM == "MGH33"
        for i in 1:length(x)
            t = 2.0 * i * ind^2
            for j in 1:length(x)
                H[i,j] = t * j
            end
        end

    # ----------------------------------------------------------------------
    # MHHM2
    elseif PROBLEM == "MHHM2"
        if ind in (1, 2, 3)
            H[1,1] = 2.0
            H[1,2] = 0.0
            H[2,1] = 0.0
            H[2,2] = 2.0
        end

    # ----------------------------------------------------------------------
    # MLF1
    elseif PROBLEM == "MLF1"
        if ind == 1
            H[1,1] = cos(x[1]) / 10 - (1 + x[1]/20) * sin(x[1])
        elseif ind == 2
            H[1,1] = -sin(x[1]) / 10 - (1 + x[1]/20) * cos(x[1])
        end

    # ----------------------------------------------------------------------
    # MLF2
    elseif PROBLEM == "MLF2"
        if ind == 1
            H[1,1] = (2 * (x[1]^2 + x[2] - 11) + 4 * x[1]^2 + 1) / 100
            H[1,2] = (2 * x[1] + 2 * x[2]) / 100
            H[2,1] = H[1,2]
            H[2,2] = (1 + 2 * (x[1] + x[2]^2 - 7) + 4 * x[2]^2) / 100

        elseif ind == 2
            H[1,1] = (8 * (4 * x[1]^2 + 2 * x[2] - 11) + 64 * x[1]^2 + 4) / 100
            H[1,2] = (16 * x[1] + 16 * x[2]) / 100
            H[2,1] = H[1,2]
            H[2,2] = (4 + 8 * (2 * x[1] + 4 * x[2]^2 - 7) + 64 * x[2]^2) / 100
        end

    # ----------------------------------------------------------------------
    # MMR1  – Box-constrained multi-objective optimization (gradient-like method)
    elseif PROBLEM == "MMR1"
        if ind == 1
            H .= 0.0
            H[1,1] = 2.0

        elseif ind == 2
            a = exp(-((x[2] - 0.6) / 0.4)^2)
            b = exp(-((x[2] - 0.2) / 0.04)^2)

            H[1,1] = (-2 * (1 + x[1]^2) + 8 * x[1]^2) / (1 + x[1]^2)^3
            H[1,1] *= (2.0 - 0.8 * a - b)

            H[1,2] = 10 * a * (x[2] - 0.6) + 1250 * b * (x[2] - 0.2)
            H[1,2] *= (-2 * x[1] / (1 + x[1]^2)^2)
            H[2,1] = H[1,2]

            H[2,2] = 10 * a + 10 * (x[2] - 0.6)^2 * a * (-12.5) +
                    1250 * b + 1250 * (x[2] - 0.2)^2 * b * (-1250)
            H[2,2] /= (1 + x[1]^2)
        end

    # ----------------------------------------------------------------------
    # MMR3
    elseif PROBLEM == "MMR3"
        if ind == 1
            H .= 0.0
            H[1,1] = 6 * x[1]

        elseif ind == 2
            H[1,1] = 6 * (x[2] - x[1])
            H[1,2] = -6 * (x[2] - x[1])
            H[2,1] = H[1,2]
            H[2,2] = 6 * (x[2] - x[1])
        end

    # ----------------------------------------------------------------------
    # MMR4
    elseif PROBLEM == "MMR4"
        if ind == 1
            t = (2 * x[1] + x[2] + 2 * x[3] + 1)^3

            H[1,1] = -288 / t
            H[1,2] = -144 / t
            H[1,3] = -288 / t

            H[2,1] = H[1,2]
            H[2,2] = -72 / t
            H[2,3] = -144 / t

            H[3,1] = H[1,3]
            H[3,2] = H[2,3]
            H[3,3] = -288 / t

        elseif ind == 2
            H .= 0.0
        end

    # ----------------------------------------------------------------------
    # MOP2
    elseif PROBLEM == "MOP2"
        b = sqrt(n)

        if ind == 1
            a = sum((x .- 1 / b).^2)
            t = exp(-a)
            for i in 1:n, j in 1:n
                H[i,j] = 2 * (x[i] - 1/b) * t * (-2 * (x[j] - 1/b))
            end
            for i in 1:n
                H[i,i] += 2 * t
            end

        elseif ind == 2
            a = sum((x .+ 1 / b).^2)
            t = exp(-a)
            for i in 1:n, j in 1:n
                H[i,j] = 2 * (x[i] + 1/b) * t * (-2 * (x[j] + 1/b))
            end
            for i in 1:n
                H[i,i] += 2 * t
            end
        end

    # ----------------------------------------------------------------------
    # MOP3
    elseif PROBLEM == "MOP3"
        if ind == 1
            A1 = 0.5 * sin(1) - 2 * cos(1) + sin(2) - 1.5 * cos(2)
            A2 = 1.5 * sin(1) - cos(1) + 2 * sin(2) - 0.5 * cos(2)
            B1 = 0.5 * sin(x[1]) - 2 * cos(x[1]) + sin(x[2]) - 1.5 * cos(x[2])
            B2 = 1.5 * sin(x[1]) - cos(x[1]) + 2 * sin(x[2]) - 0.5 * cos(x[2])

            H[1,1] = 2 * (A1 - B1) * (0.5 * sin(x[1]) - 2 * cos(x[1])) +
                    2 * (-0.5 * cos(x[1]) - 2 * sin(x[1]))^2 +
                    2 * (A2 - B2) * (1.5 * sin(x[1]) - cos(x[1])) +
                    2 * (-1.5 * cos(x[1]) - sin(x[1]))^2

            H[1,2] = 2 * (-cos(x[2]) - 1.5 * sin(x[2])) * (-0.5 * cos(x[1]) - 2 * sin(x[1])) +
                    2 * (-2 * cos(x[2]) - 0.5 * sin(x[2])) * (-1.5 * cos(x[1]) - sin(x[1]))

            H[2,1] = H[1,2]

            H[2,2] = 2 * (A1 - B1) * (sin(x[2]) - 1.5 * cos(x[2])) +
                    2 * (-cos(x[2]) - 1.5 * sin(x[2]))^2 +
                    2 * (A2 - B2) * (2 * sin(x[2]) - 0.5 * cos(x[2])) +
                    2 * (-2 * cos(x[2]) - 0.5 * sin(x[2]))^2

        elseif ind == 2
            H .= 0.0
            H[1,1] = 2.0
            H[2,2] = 2.0
        end

    # ----------------------------------------------------------------------
    # MOP5
    elseif PROBLEM == "MOP5"
        if ind == 1
            a = cos(x[1]^2 + x[2]^2)
            b = sin(x[1]^2 + x[2]^2)

            H[1,1] = 1 + 2 * a - 4 * x[1]^2 * b
            H[1,2] = -4 * x[1] * x[2] * b
            H[2,1] = H[1,2]
            H[2,2] = 1 + 2 * a - 4 * x[2]^2 * b

        elseif ind == 2
            H[1,1] = 9/4 + 2/27
            H[1,2] = -6/4 - 2/27
            H[2,1] = H[1,2]
            H[2,2] = 1 + 2/27

        elseif ind == 3
            t = x[1]^2 + x[2]^2 + 1
            a = exp(-x[1]^2 - x[2]^2)
            H[1,1] = (-2 * t + 8 * x[1]^2) / t^3 + 2.2 * a - 4.4 * x[1]^2 * a
            H[1,2] = 8 * x[1] * x[2] / t^3 - 4.4 * x[1] * x[2] * a
            H[2,1] = H[1,2]
            H[2,2] = (-2 * t + 8 * x[2]^2) / t^3 + 2.2 * a - 4.4 * x[2]^2 * a
        end

    # ----------------------------------------------------------------------
    # MOP6
    elseif PROBLEM == "MOP6"
        if ind == 1
            H .= 0.0
        elseif ind == 2
            a = 1 + 10 * x[2]
            b = sin(8π * x[1])
            c = cos(8π * x[1])
            t = x[1] / a

            H[1,1] = -2 / a - 16π * c + 64π^2 * x[1] * b
            H[1,2] = 20 * x[1] / a^2
            H[2,1] = H[1,2]
            H[2,2] = -20 * t * (-10 * x[1] / a^2) +
                    100 * x[1] * b / a^2 -
                    100 * x[1] / a^2 * (2 * t + b) +
                    10 * x[1] / a * (-20 * x[1] / a^2)
        end

    # ----------------------------------------------------------------------
    # MOP7
    elseif PROBLEM == "MOP7"
        if ind == 1
            H .= 0.0
            H[1,1] = 1.0
            H[2,2] = 2 / 13

        elseif ind == 2
            H[1,1] = 1/18 + 1/4
            H[1,2] = 1/18 - 1/4
            H[2,1] = H[1,2]
            H[2,2] = 1/18 + 1/4

        elseif ind == 3
            H[1,1] = 2/175 + 2/17
            H[1,2] = 4/175 - 4/17
            H[2,1] = H[1,2]
            H[2,2] = 8/175 + 8/17
        end

    # ----------------------------------------------------------------------
    # PNR
    elseif PROBLEM == "PNR"
        if ind == 1
            H[1,1] = 12 * x[1]^2 - 2
            H[1,2] = -10
            H[2,1] = H[1,2]
            H[2,2] = 12 * x[2]^2 + 2
        elseif ind == 2
            H[1,1] = 2
            H[1,2] = 0
            H[2,1] = 0
            H[2,2] = 2
        end

    # ----------------------------------------------------------------------
    # QV1
    elseif PROBLEM == "QV1"
        if ind == 1
            t = sum(x.^2 .- 10 .* cos.(2π .* x) .+ 10) / n
            for i in 1:n
                a = (2 * x[i] + 20π * sin(2π * x[i])) / n
                for j in 1:n
                    H[i,j] = -0.1875 * t^(-1.75) * (2 * x[j] + 20π * sin(2π * x[j])) / n * a
                end
            end
            for i in 1:n
                H[i,i] += 0.25 * t^(-0.75) * (2 + 40π^2 * cos(2π * x[i])) / n
            end

        elseif ind == 2
            t = sum((x .- 1.5).^2 .- 10 .* cos.(2π .* (x .- 1.5)) .+ 10) / n
            for i in 1:n
                a = (2 * (x[i] - 1.5) + 20π * sin(2π * (x[i] - 1.5))) / n
                for j in 1:n
                    H[i,j] = -0.1875 * t^(-1.75) *
                            (2 * (x[j] - 1.5) + 20π * sin(2π * (x[j] - 1.5))) / n * a
                end
            end
            for i in 1:n
                H[i,i] += 0.25 * t^(-0.75) *
                        (2 + 40π^2 * cos(2π * (x[i] - 1.5))) / n
            end
        end

    # ----------------------------------------------------------------------
    # SD
    elseif PROBLEM == "SD"
        if ind == 1
            H .= 0.0
        elseif ind == 2
            H .= 0.0
            H[1,1] = 4 / x[1]^3
            H[2,2] = 4 * sqrt(2) / x[2]^3
            H[3,3] = 4 * sqrt(2) / x[3]^3
            H[4,4] = 4 / x[4]^3
        end

    # ----------------------------------------------------------------------
    # SLCDT1
    elseif PROBLEM == "SLCDT1"
        a = 1 + (x[1] + x[2])^2
        b = 1 + (x[1] - x[2])^2
        c = exp(-(x[1] + x[2])^2)

        H[1,1] = 0.5 * (sqrt(a) - (x[1] + x[2])^2 / sqrt(a)) / a +
                0.5 * (sqrt(b) - (x[1] - x[2])^2 / sqrt(b)) / b -
                2 * 0.85 * c + 4 * 0.85 * (x[1] + x[2])^2 * c

        H[1,2] = 0.5 * (sqrt(a) - (x[1] + x[2])^2 / sqrt(a)) / a +
                0.5 * (-sqrt(b) + (x[1] - x[2])^2 / sqrt(b)) / b -
                2 * 0.85 * c + 4 * 0.85 * (x[1] + x[2])^2 * c

        H[2,1] = H[1,2]

        H[2,2] = 0.5 * (sqrt(a) - (x[1] + x[2])^2 / sqrt(a)) / a -
                0.5 * (-sqrt(b) + (x[1] - x[2])^2 / sqrt(b)) / b -
                2 * 0.85 * c + 4 * 0.85 * (x[1] + x[2])^2 * c

    # ----------------------------------------------------------------------
    # SLCDT2
    elseif PROBLEM == "SLCDT2"
        if ind == 1
            H .= 0.0
            H[1,1] = 12 * (x[1] - 1)^2
            for i in 2:n
                H[i,i] = 2.0
            end

        elseif ind == 2
            H .= 0.0
            H[2,2] = 12 * (x[2] + 1)^2
            for i in 1:n
                if i != 2
                    H[i,i] = 2.0
                end
            end

        elseif ind == 3
            H .= 0.0
            H[3,3] = 12 * (x[3] - 1)^2
            for i in 1:n
                if i != 3
                    H[i,i] = 2.0
                end
            end
        end

    # ----------------------------------------------------------------------
    # SP1
    elseif PROBLEM == "SP1"
        if ind == 1
            H[1,1] = 4
            H[1,2] = -2
            H[2,1] = -2
            H[2,2] = 2
        elseif ind == 2
            H[1,1] = 2
            H[1,2] = -2
            H[2,1] = -2
            H[2,2] = 4
        end

    # ----------------------------------------------------------------------
    # SSFYY2
    elseif PROBLEM == "SSFYY2"
        if ind == 1
            H[1,1] = 2 + 2.5 * π^2 * cos(x[1] * π / 2)
        elseif ind == 2
            H[1,1] = 2.0
        end

    # ----------------------------------------------------------------------
    # SK1
    elseif PROBLEM == "SK1"
        if ind == 1
            H[1,1] = 12 * x[1]^2 + 18 * x[1] - 20
        elseif ind == 2
            H[1,1] = 6 * x[1]^2 - 12 * x[1] - 20
        end

    # ----------------------------------------------------------------------
    # SK2
    elseif PROBLEM == "SK2"
        if ind == 1
            H .= 0.0
            for i in 1:4
                H[i,i] = 2.0
            end

        elseif ind == 2
            a = 1 + (sum(x.^2)) / 100
            b = sum(sin.(x))
            for i in 1:n
                for j in 1:n
                    H[i,j] = (-cos(x[i]) * x[j] / 50 + cos(x[j]) * x[i] / 50) * a^2 -
                            (-cos(x[i]) * a + b * x[i] / 50) * 2 * a * x[j] / 50
                    H[i,j] /= a^4
                    if i == j
                        H[i,j] += (sin(x[i]) * a + b / 50) / a^2
                    end
                end
            end
        end

    # ----------------------------------------------------------------------
    # TKLY1
    elseif PROBLEM == "TKLY1"
        if ind == 1
            H .= 0.0

        elseif ind == 2
            A1 = 2 - exp(-((x[2] - 0.1) / 4e-3)^2) -
                    0.8 * exp(-((x[2] - 0.9) / 4e-1)^2)
            A2 = 2 - exp(-((x[3] - 0.1) / 4e-3)^2) -
                    0.8 * exp(-((x[3] - 0.9) / 4e-1)^2)
            A3 = 2 - exp(-((x[4] - 0.1) / 4e-3)^2) -
                    0.8 * exp(-((x[4] - 0.9) / 4e-1)^2)

            H[1,1] = 2 * A1 * A2 * A3 / x[1]^3
            H[1,2] = -A2 * A3 / x[1]^2 *
                    (5e2 * exp(-((x[2] - 0.1)/4e-3)^2) * ((x[2] - 0.1)/4e-3) +
                    4 * exp(-((x[2] - 0.9)/4e-1)^2) * ((x[2] - 0.9)/4e-1))
            H[1,3] = -A1 * A3 / x[1]^2 *
                    (5e2 * exp(-((x[3] - 0.1)/4e-3)^2) * ((x[3] - 0.1)/4e-3) +
                    4 * exp(-((x[3] - 0.9)/4e-1)^2) * ((x[3] - 0.9)/4e-1))
            H[1,4] = -A1 * A2 / x[1]^2 *
                    (5e2 * exp(-((x[4] - 0.1)/4e-3)^2) * ((x[4] - 0.1)/4e-3) +
                    4 * exp(-((x[4] - 0.9)/4e-1)^2) * ((x[4] - 0.9)/4e-1))

            H[2,1] = H[1,2]
            H[2,2] = A2 * A3 / x[1] *
                    (5e2 * exp(-((x[2] - 0.1)/4e-3)^2) / 4e-3 -
                    (5e2)^2 * exp(-((x[2] - 0.1)/4e-3)^2) * ((x[2] - 0.1)/4e-3)^2 +
                    4 * exp(-((x[2] - 0.9)/4e-1)^2) / 4e-1 -
                    20 * exp(-((x[2] - 0.9)/4e-1)^2) * ((x[2] - 0.9)/4e-1)^2)
            H[2,3] = A3 / x[1] *
                    (5e2 * exp(-((x[2] - 0.1)/4e-3)^2) * ((x[2] - 0.1)/4e-3) +
                    4 * exp(-((x[2] - 0.9)/4e-1)^2) * ((x[2] - 0.9)/4e-1)) *
                    (5e2 * exp(-((x[3] - 0.1)/4e-3)^2) * ((x[3] - 0.1)/4e-3) +
                    4 * exp(-((x[3] - 0.9)/4e-1)^2) * ((x[3] - 0.9)/4e-1))
            H[2,4] = A2 / x[1] *
                    (5e2 * exp(-((x[2] - 0.1)/4e-3)^2) * ((x[2] - 0.1)/4e-3) +
                    4 * exp(-((x[2] - 0.9)/4e-1)^2) * ((x[2] - 0.9)/4e-1)) *
                    (5e2 * exp(-((x[4] - 0.1)/4e-3)^2) * ((x[4] - 0.1)/4e-3) +
                    4 * exp(-((x[4] - 0.9)/4e-1)^2) * ((x[4] - 0.9)/4e-1))

            H[3,1] = H[1,3]
            H[3,2] = H[2,3]
            H[3,3] = A1 * A3 / x[1] *
                    (5e2 * exp(-((x[3] - 0.1)/4e-3)^2) / 4e-3 -
                    (5e2)^2 * exp(-((x[3] - 0.1)/4e-3)^2) * ((x[3] - 0.1)/4e-3)^2 +
                    4 * exp(-((x[3] - 0.9)/4e-1)^2) / 4e-1 -
                    20 * exp(-((x[3] - 0.9)/4e-1)^2) * ((x[3] - 0.9)/4e-1)^2)
            H[3,4] = A1 / x[1] *
                    (5e2 * exp(-((x[3] - 0.1)/4e-3)^2) * ((x[3] - 0.1)/4e-3) +
                    4 * exp(-((x[3] - 0.9)/4e-1)^2) * ((x[3] - 0.9)/4e-1)) *
                    (5e2 * exp(-((x[4] - 0.1)/4e-3)^2) * ((x[4] - 0.1)/4e-3) +
                    4 * exp(-((x[4] - 0.9)/4e-1)^2) * ((x[4] - 0.9)/4e-1))

            H[4,1] = H[1,4]
            H[4,2] = H[2,4]
            H[4,3] = H[3,4]
            H[4,4] = A1 * A2 / x[1] *
                    (5e2 * exp(-((x[4] - 0.1)/4e-3)^2) / 4e-3 -
                    (5e2)^2 * exp(-((x[4] - 0.1)/4e-3)^2) * ((x[4] - 0.1)/4e-3)^2 +
                    4 * exp(-((x[4] - 0.9)/4e-1)^2) / 4e-1 -
                    20 * exp(-((x[4] - 0.9)/4e-1)^2) * ((x[4] - 0.9)/4e-1)^2)
        end

    # ----------------------------------------------------------------------
    # Toi4
    elseif PROBLEM == "Toi4"
        if ind == 1
            H .= 0.0
            for i in 1:2
                H[i,i] = 2.0
            end
        elseif ind == 2
            H .= 0.0
            H[1,1] = 1.0; H[1,2] = -1.0
            H[2,1] = -1.0; H[2,2] = 1.0
            H[3,3] = 1.0;  H[3,4] = -1.0
            H[4,3] = -1.0; H[4,4] = 1.0
        end

    # ----------------------------------------------------------------------
    # Toi8
    elseif PROBLEM == "Toi8"
        if ind == 1
            H .= 0.0
            H[1,1] = 8.0
        else
            H .= 0.0
            H[ind-1,ind-1] = 8.0 * ind
            H[ind-1,ind]   = -4.0 * ind
            H[ind,ind-1]   = H[ind-1,ind]
            H[ind,ind]     = 2.0 * ind
        end

    # ----------------------------------------------------------------------
    # Toi9
    elseif PROBLEM == "Toi9"
        if ind == 1
            H .= 0.0
            H[1,1] = 8.0
            H[2,2] = 2.0
        elseif 1 < ind < n
            H .= 0.0
            H[ind-1,ind-1] = 6.0 * ind + 2.0
            H[ind-1,ind]   = -4.0 * ind
            H[ind,ind-1]   = -4.0 * ind
            H[ind,ind]     = 4.0 * ind
        elseif ind == n
            H .= 0.0
            H[n-1,n-1] = 6.0 * n + 2.0
            H[n-1,n]   = -4.0 * n
            H[n,n-1]   = -4.0 * n
            H[n,n]     = 2.0 * n
        end

    # ----------------------------------------------------------------------
    # Toi10 (Rosenbrock)
    elseif PROBLEM == "Toi10"
        H .= 0.0
        H[ind,ind]     = 800 * x[ind]^2 - 400 * (x[ind+1] - x[ind]^2)
        H[ind,ind+1]   = -400 * x[ind]
        H[ind+1,ind]   = H[ind,ind+1]
        H[ind+1,ind+1] = 202.0

    # ----------------------------------------------------------------------
    # VU1
    elseif PROBLEM == "VU1"
        if ind == 1
            a = x[1]^2 + x[2]^2 + 1
            H[1,1] = (-2 * a + 8 * x[1]^2) / a^3
            H[1,2] = 8 * x[1] * x[2] / a^3
            H[2,1] = H[1,2]
            H[2,2] = (-2 * a + 8 * x[2]^2) / a^3
        elseif ind == 2
            H[1,1] = 2
            H[1,2] = 0
            H[2,1] = 0
            H[2,2] = 6
        end

    # ----------------------------------------------------------------------
    # VU2
    elseif PROBLEM == "VU2"
        if ind == 1
            H .= 0.0
        elseif ind == 2
            H .= 0.0
            H[1,1] = 2.0
        end

    # ----------------------------------------------------------------------
    # ZDT1
    elseif PROBLEM == "ZDT1"
        if ind == 1
            H .= 0.0
        elseif ind == 2
            a = 1.0 + 9.0 * sum(x[2:n]) / (n - 1)
            t = x[1] / a

            H[1,1] = 0.25 * t^(-1.5) / a
            for j in 2:n
                H[1,j] = 0.25 * t^(-1.5) * (-x[1] * 9.0 / (n - 1) / a^2)
            end

            b = -2.25 / (n - 1) * t^(-0.5) * (-x[1] * 9.0 / (n - 1) / a^2)
            for i in 2:n, j in i:n
                H[i,j] = b
            end
            for i in 2:n, j in 1:i-1
                H[i,j] = H[j,i]
            end
        end

    # ----------------------------------------------------------------------
    # ZDT2
    elseif PROBLEM == "ZDT2"
        if ind == 1
            H .= 0.0
        elseif ind == 2
            a = 1.0 + 9.0 * sum(x[2:n]) / (n - 1)
            t = x[1] / a

            H[1,1] = -2.0 / a
            for j in 2:n
                H[1,j] = -2.0 * (-x[1] * 9.0 / (n - 1) / a^2)
            end

            b = 18.0 / (n - 1) * t * (-x[1] * 9.0 / (n - 1) / a^2)
            for i in 2:n, j in i:n
                H[i,j] = b
            end
            for i in 2:n, j in 1:i-1
                H[i,j] = H[j,i]
            end
        end

    # ----------------------------------------------------------------------
    # ZDT3
    elseif PROBLEM == "ZDT3"
        if ind == 1
            H .= 0.0
        elseif ind == 2
            a = 1.0 + 9.0 * sum(x[2:n]) / (n - 1)
            t = x[1] / a

            H[1,1] = 0.25 * t^(-1.5) / a - 20.0 * π * cos(10π * x[1]) + 100.0 * π^2 * x[1] * sin(10π * x[1])
            for j in 2:n
                H[1,j] = 0.25 * t^(-1.5) * (-x[1] * 9.0 / (n - 1) / a^2)
            end

            b = -2.25 / (n - 1) * t^(-0.5) * (-x[1] * 9.0 / (n - 1) / a^2)
            for i in 2:n, j in i:n
                H[i,j] = b
            end
            for i in 2:n, j in 1:i-1
                H[i,j] = H[j,i]
            end
        end

    # ----------------------------------------------------------------------
    # ZDT4
    elseif PROBLEM == "ZDT4"
        if ind == 1
            H .= 0.0
        elseif ind == 2
            a = sum(x[2:n].^2 .- 10.0 .* cos.(4π .* x[2:n])) + 1.0 + 10.0 * (n - 1)
            t = x[1] / a

            H[1,1] = 0.25 * t^(-1.5) / a
            for j in 2:n
                H[1,j] = 0.25 * t^(-1.5) * (-x[1] * (2.0 * x[j] + 40.0 * π * sin(4π * x[j])) / a^2)
            end

            for i in 2:n
                b = sin(4π * x[i])
                for j in i:n
                    H[i,j] = (2.0 * x[i] + 40.0 * π * b) *
                            (-0.25 * t^(-0.5) * (-x[1] * (2.0 * x[j] + 40.0 * π * sin(4π * x[j])) / a^2))
                    if j == i
                        H[i,j] += (2.0 + 160.0 * π^2 * cos(4π * x[i])) * (1.0 - sqrt(t) / 2.0)
                    end
                end
            end
            for i in 2:n, j in 1:i-1
                H[i,j] = H[j,i]
            end
        end

    # ----------------------------------------------------------------------
    # ZDT6
    elseif PROBLEM == "ZDT6"
        if ind == 1
            a = exp(-4.0 * x[1])
            b = sin(6.0 * π * x[1])
            c = cos(6.0 * π * x[1])
            H .= 0.0
            H[1,1] = -4.0 * a * (4.0 * b^6 - 36.0 * π * b^5 * c) +
                    a * (144.0 * π * b^5 * c - 1080.0 * π^2 * b^4 * c^2 + 216.0 * π^2 * b^6)
        elseif ind == 2
            a = exp(-4.0 * x[1])
            b = sin(6.0 * π * x[1])
            c = cos(6.0 * π * x[1])
            gaux1 = 1.0 - a * b^6
            gaux2 = 1.0 + 9.0 * (sum(x[2:n]) / (n - 1))^0.25
            t = gaux1 / gaux2

            A1 = 2.25 / (n - 1) * (sum(x[2:n]) / (n - 1))^(-0.75)
            A2 = -2.25 * 0.75 / (n - 1)^2 * (sum(x[2:n]) / (n - 1))^(-1.75)

            H[1,1] = (8.0 * t * a - 2.0 * (4.0 * a * b^6 - 36.0 * π * a * b^5 * c) / gaux2 * a) *
                    (4.0 * b^6 - 36.0 * π * b^5 * c) -
                    2.0 * t * a * (144.0 * π * b^5 * c - 1080.0 * π^2 * b^4 * c^2 + 216.0 * π^2 * b^6)

            for j in 2:n
                H[1,j] = -2.0 * a * (4.0 * b^6 - 36.0 * π * b^5 * c) * (-gaux1 * A1 / gaux2^2)
            end

            for i in 2:n, j in i:n
                H[i,j] = A2 * (1.0 + t^2) + A1 * 2.0 * t * (-gaux1 * A1 / gaux2^2)
            end
            for i in 2:n, j in 1:i-1
                H[i,j] = H[j,i]
            end
        end

    # ----------------------------------------------------------------------
    # ZLT1
    elseif PROBLEM == "ZLT1"
        H .= 0.0
        for i in 1:n
            H[i,i] = 2.0
        end
    else
        # error("Unknown problem: $PROBLEM")
    end
end