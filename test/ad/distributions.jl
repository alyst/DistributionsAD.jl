@testset "distributions" begin
    Random.seed!(1234)

    # Create random vectors and matrices
    dim = 3
    a = rand(dim)
    b = rand(dim)
    c = rand(dim)
    A = rand(dim, dim)
    B = rand(dim, dim)
    C = rand(dim, dim)

    # Create random numbers
    alpha = rand()
    beta = rand()
    gamma = rand()

    # Create matrix `X` such that `X` and `I - X` are positive definite if `A ≠ 0`.
    function to_beta_mat(A)
        S = A * A' + I
        invL = inv(cholesky(S).L)
        return invL * invL'
    end

    # Create positive values.
    to_positive(x) = exp.(x)
    to_positive(x::AbstractArray{<:AbstractArray}) = to_positive.(x)

    # The following definition should not be needed
    # It seems there is a bug in the default `rand_tangent` that causes a
    # StackOverflowError though
    function ChainRulesTestUtils.rand_tangent(::Random.AbstractRNG, ::typeof(to_positive))
        return NoTangent()
    end

    # Tests that have a `broken` field can be executed but, according to FiniteDifferences,
    # fail to produce the correct result. These tests can be checked with `@test_broken`.
    univariate_distributions = DistSpec[
        ## Univariate discrete distributions

        DistSpec(Bernoulli, (0.45,), 1),
        DistSpec(Bernoulli, (0.45,), [1, 1]),
        DistSpec(Bernoulli, (0.45,), 0),
        DistSpec(Bernoulli, (0.45,), [0, 0]),

        DistSpec((a, b) -> BetaBinomial(10, a, b), (2.0, 1.0), 5),
        DistSpec((a, b) -> BetaBinomial(10, a, b), (2.0, 1.0), [5, 5]),

        DistSpec(p -> Binomial(10, p), (0.5,), 5),
        DistSpec(p -> Binomial(10, p), (0.5,), [5, 5]),

        DistSpec(p -> Categorical(p / sum(p)), ([0.45, 0.55],), 1),
        DistSpec(p -> Categorical(p / sum(p)), ([0.45, 0.55],), [1, 1]),

        DistSpec(Geometric, (0.45,), 3),
        DistSpec(Geometric, (0.45,), [3, 3]),

        DistSpec(NegativeBinomial, (3.5, 0.5), 1),
        DistSpec(NegativeBinomial, (3.5, 0.5), [1, 1]),

        DistSpec(Poisson, (0.5,), 1),
        DistSpec(Poisson, (0.5,), [1, 1]),

        DistSpec(Skellam, (1.0, 2.0), -2),
        DistSpec(Skellam, (1.0, 2.0), [-2, -2]),

        DistSpec(PoissonBinomial, ([0.5, 0.5],), 0),

        DistSpec(TuringPoissonBinomial, ([0.5, 0.5],), 0),
        DistSpec(TuringPoissonBinomial, ([0.5, 0.5],), [0, 0]),

        ## Univariate continuous distributions

        DistSpec(Arcsine, (), 0.5),
        DistSpec(Arcsine, (1.0,), 0.5),
        DistSpec(Arcsine, (0.0, 2.0), 0.5),

        DistSpec(Beta, (), 0.4),
        DistSpec(Beta, (1.5,), 0.4),
        DistSpec(Beta, (1.5, 2.0), 0.4),

        DistSpec(BetaPrime, (), 0.4),
        DistSpec(BetaPrime, (1.5,), 0.4),
        DistSpec(BetaPrime, (1.5, 2.0), 0.4),

        DistSpec(Biweight, (), 0.5),
        DistSpec(Biweight, (1.0,), 0.5),
        DistSpec(Biweight, (1.0, 2.0), 0.5),

        DistSpec(Cauchy, (), 0.5),
        DistSpec(Cauchy, (1.0,), 0.5),
        DistSpec(Cauchy, (1.0, 2.0), 0.5),

        DistSpec(Chernoff, (), 0.5, broken=(:Zygote,)),

        DistSpec(Chi, (1.0,), 0.5),

        DistSpec(Chisq, (1.0,), 0.5),

        DistSpec(Cosine, (1.0, 1.0), 0.5),

        DistSpec(Epanechnikov, (1.0, 1.0), 0.5),

        DistSpec(s -> Erlang(1, s), (1.0,), 0.5), # First arg is integer

        DistSpec(Exponential, (1.0,), 0.5),

        DistSpec(FDist, (1.0, 1.0), 0.5),

        DistSpec(Frechet, (), 0.5),
        DistSpec(Frechet, (1.0,), 0.5),
        DistSpec(Frechet, (1.0, 2.0), 0.5),

        DistSpec(Gamma, (), 0.4),
        DistSpec(Gamma, (1.5,), 0.4),
        DistSpec(Gamma, (1.5, 2.0), 0.4),

        DistSpec(GeneralizedExtremeValue, (1.0, 1.0, 1.0), 0.5),

        DistSpec(GeneralizedPareto, (), 0.5),
        DistSpec(GeneralizedPareto, (1.0, 2.0), 0.5),
        DistSpec(GeneralizedPareto, (0.0, 2.0, 3.0), 0.5),

        DistSpec(Gumbel, (), 0.5),
        DistSpec(Gumbel, (1.0,), 0.5),
        DistSpec(Gumbel, (1.0, 2.0), 0.5),

        DistSpec(InverseGamma, (), 0.5),
        DistSpec(InverseGamma, (1.0,), 0.5),
        DistSpec(InverseGamma, (1.0, 2.0), 0.5),

        DistSpec(InverseGaussian, (), 0.5),
        DistSpec(InverseGaussian, (1.0,), 0.5),
        DistSpec(InverseGaussian, (1.0, 2.0), 0.5),

        DistSpec(Kolmogorov, (), 0.5),

        DistSpec(Laplace, (), 0.5),
        DistSpec(Laplace, (1.0,), 0.5),
        DistSpec(Laplace, (1.0, 2.0), 0.5),

        DistSpec(Levy, (), 0.5),
        DistSpec(Levy, (0.0,), 0.5),
        DistSpec(Levy, (0.0, 2.0), 0.5),

        DistSpec((a, b) -> LocationScale(a, b, Normal()), (1.0, 2.0), 0.5),

        DistSpec(Logistic, (), 0.5),
        DistSpec(Logistic, (1.0,), 0.5),
        DistSpec(Logistic, (1.0, 2.0), 0.5),

        DistSpec(LogitNormal, (), 0.5),
        DistSpec(LogitNormal, (1.0,), 0.5),
        DistSpec(LogitNormal, (1.0, 2.0), 0.5),

        DistSpec(LogNormal, (), 0.5),
        DistSpec(LogNormal, (1.0,), 0.5),
        DistSpec(LogNormal, (1.0, 2.0), 0.5),

        # Dispatch error caused by ccall
        DistSpec(NoncentralBeta, (1.0, 2.0, 1.0), 0.5, broken=(:Tracker, :ForwardDiff, :Zygote, :ReverseDiff)),
        DistSpec(NoncentralChisq, (1.0, 2.0), 0.5, broken=(:Tracker, :ForwardDiff, :Zygote, :ReverseDiff)),
        DistSpec(NoncentralF, (1.0, 2.0, 1.0), 0.5, broken=(:Tracker, :ForwardDiff, :Zygote, :ReverseDiff)),
        DistSpec(NoncentralT, (1.0, 2.0), 0.5, broken=(:Tracker, :ForwardDiff, :Zygote, :ReverseDiff)),

        DistSpec(Normal, (), 0.5),
        DistSpec(Normal, (1.0,), 0.5),
        DistSpec(Normal, (1.0, 2.0), 0.5),

        DistSpec(NormalCanon, (1.0, 2.0), 0.5),

        DistSpec(NormalInverseGaussian, (1.0, 2.0, 1.0, 1.0), 0.5),

        DistSpec(Pareto, (), 1.5),
        DistSpec(Pareto, (1.0,), 1.5),
        DistSpec(Pareto, (1.0, 1.0), 1.5),

        DistSpec(PGeneralizedGaussian, (), 0.5),
        DistSpec(PGeneralizedGaussian, (1.0, 1.0, 1.0), 0.5),

        DistSpec(Rayleigh, (), 0.5),
        DistSpec(Rayleigh, (1.0,), 0.5),

        DistSpec(Semicircle, (1.0,), 0.5),

        DistSpec(SymTriangularDist, (), 0.5),
        DistSpec(SymTriangularDist, (1.0,), 0.5),
        DistSpec(SymTriangularDist, (1.0, 2.0), 0.5),

        DistSpec(TDist, (1.0,), 0.5),

        DistSpec(TriangularDist, (1.0, 3.0), 1.5),
        DistSpec(TriangularDist, (1.0, 3.0, 2.0), 1.5),

        DistSpec(Triweight, (1.0, 1.0), 1.0),

        DistSpec(
            (mu, sigma, l, u) -> truncated(Normal(mu, sigma), l, u), (0.0, 1.0, 1.0, 2.0), 1.5
        ),

        DistSpec(Uniform, (), 0.5),
        DistSpec(Uniform, (alpha, alpha + beta), alpha + beta * gamma),

        DistSpec(VonMises, (), 1.0),

        DistSpec(Weibull, (), 1.0),
        DistSpec(Weibull, (1.0,), 1.0),
        DistSpec(Weibull, (1.0, 1.0), 1.0),
    ]

    # Tests cannot be executed, so cannot be checked with `@test_broken`.
    broken_univariate_distributions = DistSpec[
        # Broken in Distributions even without autodiff
        DistSpec(() -> KSDist(1), (), 0.5), # `pdf` method not defined
        DistSpec(() -> KSOneSided(1), (), 0.5), # `pdf` method not defined
        DistSpec(StudentizedRange, (1.0, 2.0), 0.5), # `srdistlogpdf` method not defined

        # Stackoverflow caused by SpecialFunctions.besselix
        DistSpec(VonMises, (1.0,), 1.0),
        DistSpec(VonMises, (1, 1), 1),

        # Some tests are broken on some Julia versions, therefore it can't be checked reliably
        DistSpec(PoissonBinomial, ([0.5, 0.5],), [0, 0]; broken=(:Zygote,)),
    ]

    # Tests that have a `broken` field can be executed but, according to FiniteDifferences,
    # fail to produce the correct result. These tests can be checked with `@test_broken`.
    multivariate_distributions = DistSpec[
        ## Multivariate discrete distributions

        # Vector x
        DistSpec(p -> Multinomial(2, p ./ sum(p)), (fill(0.5, 2),), [2, 0]),
        DistSpec(p -> Multinomial(2, p ./ sum(p)), (fill(0.5, 2),), [2 1; 0 1]),

        # Vector x
        DistSpec((m, A) -> MvNormal(m, to_posdef(A)), (a, A), b),
        DistSpec((m, s) -> MvNormal(m, to_posdef_diagonal(s)), (a, b), c),
        DistSpec((m, s) -> MvNormal(m, s^2 * I), (a, alpha), b),
        DistSpec(A -> MvNormal(to_posdef(A)), (A,), a),
        DistSpec(s -> MvNormal(to_posdef_diagonal(s)), (a,), b),
        DistSpec(s -> MvNormal(zeros(dim), s^2 * I), (alpha,), a),
        DistSpec((m, A) -> TuringMvNormal(m, to_posdef(A)), (a, A), b),
        DistSpec((m, s) -> TuringMvNormal(m, to_posdef_diagonal(s)), (a, b), c),
        DistSpec((m, s) -> TuringMvNormal(m, s^2 * I), (a, alpha), b),
        DistSpec(A -> TuringMvNormal(to_posdef(A)), (A,), a),
        DistSpec(s -> TuringMvNormal(to_posdef_diagonal(s)), (a,), b),
        DistSpec(s -> TuringMvNormal(zeros(dim), s^2 * I), (alpha,), a),
        DistSpec((m, A) -> MvLogNormal(m, to_posdef(A)), (a, A), b, to_positive),
        DistSpec((m, s) -> MvLogNormal(m, to_posdef_diagonal(s)), (a, b), c, to_positive),
        DistSpec((m, s) -> MvLogNormal(m, s^2 * I), (a, alpha), b, to_positive),
        DistSpec(A -> MvLogNormal(to_posdef(A)), (A,), a, to_positive),
        DistSpec(s -> MvLogNormal(to_posdef_diagonal(s)), (a,), b, to_positive),
        DistSpec(s -> MvLogNormal(zeros(dim), s^2 * I), (alpha,), a, to_positive),

        DistSpec(alpha -> Dirichlet(to_positive(alpha)), (a,), b, to_simplex),

        # Matrix case
        DistSpec((m, A) -> MvNormal(m, to_posdef(A)), (a, A), B),
        DistSpec((m, s) -> MvNormal(m, to_posdef_diagonal(s)), (a, b), A),
        DistSpec((m, s) -> MvNormal(m, s^2 * I), (a, alpha), A),
        DistSpec(A -> MvNormal(to_posdef(A)), (A,), B),
        DistSpec(s -> MvNormal(to_posdef_diagonal(s)), (a,), A),
        DistSpec(s -> MvNormal(zeros(dim), s^2 * I), (alpha,), A),
        DistSpec((m, A) -> TuringMvNormal(m, to_posdef(A)), (a, A), B),
        DistSpec((m, s) -> TuringMvNormal(m, to_posdef_diagonal(s)), (a, b), A),
        DistSpec((m, s) -> TuringMvNormal(m, s^2 * I), (a, alpha), A),
        DistSpec(A -> TuringMvNormal(to_posdef(A)), (A,), B),
        DistSpec(s -> TuringMvNormal(to_posdef_diagonal(s)), (a,), A),
        DistSpec(s -> TuringMvNormal(zeros(dim), s^2 * I), (alpha,), A),
        DistSpec((m, A) -> MvLogNormal(m, to_posdef(A)), (a, A), B, to_positive),
        DistSpec((m, s) -> MvLogNormal(m, to_posdef_diagonal(s)), (a, b), A, to_positive),
        DistSpec((m, s) -> MvLogNormal(m, s^2 * I), (a, alpha), A, to_positive),
        DistSpec(A -> MvLogNormal(to_posdef(A)), (A,), B, to_positive),
        DistSpec(s -> MvLogNormal(to_posdef_diagonal(s)), (a,), A, to_positive),
        DistSpec(s -> MvLogNormal(zeros(dim), s^2 * I), (alpha,), A, to_positive),

        DistSpec(alpha -> Dirichlet(to_positive(alpha)), (a,), A, to_simplex),
    ]

    # Tests cannot be executed, so cannot be checked with `@test_broken`.
    broken_multivariate_distributions = DistSpec[
        # Dispatch error
        DistSpec((m, A) -> MvNormalCanon(m, to_posdef(A)), (a, A), b),
        DistSpec((m, p) -> MvNormalCanon(m, to_posdef_diagonal(p)), (a, b), c),
        DistSpec((m, p) -> MvNormalCanon(m, p^2 * I), (a, alpha), b),
        DistSpec(A -> MvNormalCanon(to_posdef(A)), (A,), a),
        DistSpec(p -> MvNormalCanon(to_posdef_diagonal(p)), (a,), b),
        DistSpec(p -> MvNormalCanon(zeros(dim), p^2 * I), (alpha,), a),
        DistSpec((m, A) -> MvNormalCanon(m, to_posdef(A)), (a, A), B),
        DistSpec((m, p) -> MvNormalCanon(m, to_posdef_diagonal(p)), (a, b), A),
        DistSpec((m, p) -> MvNormalCanon(m, p^2 * I), (a, alpha), A),
        DistSpec(A -> MvNormalCanon(to_posdef(A)), (A,), B),
        DistSpec(p -> MvNormalCanon(to_posdef_diagonal(p)), (a,), A),
        DistSpec(p -> MvNormalCanon(zeros(dim), p^2 * I), (alpha,), A),
    ]

    # Tests that have a `broken` field can be executed but, according to FiniteDifferences,
    # fail to produce the correct result. These tests can be checked with `@test_broken`.
    matrixvariate_distributions = DistSpec[
        # Matrix x
        # We should use
        # DistSpec((n1, n2) -> MatrixBeta(dim, n1, n2), (3.0, 3.0), A, to_beta_mat),
        # but the default implementation of `rand_tangent` causes a StackOverflowError
        # Thus we use the following workaround
        DistSpec((n1, n2) -> MatrixBeta(3, n1, n2), (3.0, 3.0), A, to_beta_mat),
        DistSpec(() -> MatrixNormal(dim, dim), (), A, to_posdef, broken=(:Zygote,)),
        DistSpec((df, A) -> Wishart(df, to_posdef(A)), (3.0, A), B, to_posdef),
        DistSpec((df, A) -> InverseWishart(df, to_posdef(A)), (3.0, A), B, to_posdef),
        DistSpec((df, A) -> TuringWishart(df, to_posdef(A)), (3.0, A), B, to_posdef),
        DistSpec((df, A) -> TuringInverseWishart(df, to_posdef(A)), (3.0, A), B, to_posdef),

        # Vector of matrices x
        # Also here we should use
        # DistSpec(
        #    (n1, n2) -> MatrixBeta(dim, n1, n2),
        #    (3.0, 3.0),
        #    [A, B],
        #    x -> map(to_beta_mat, x),
        #),
        # but the default implementation of `rand_tangent` causes a StackOverflowError
        # Thus we use the following workaround
        DistSpec(
            (n1, n2) -> MatrixBeta(3, n1, n2),
            (3.0, 3.0),
            [A, B],
            x -> map(to_beta_mat, x),
        ),
        DistSpec(
            (df, A) -> Wishart(df, to_posdef(A)),
            (3.0, A),
            [B, C],
            x -> map(to_posdef, x),
        ),
        DistSpec(
            (df, A) -> InverseWishart(df, to_posdef(A)),
            (3.0, A),
            [B, C],
            x -> map(to_posdef, x),
        ),
        DistSpec(
            (df, A) -> TuringWishart(df, to_posdef(A)),
            (3.0, A),
            [B, C],
            x -> map(to_posdef, x),
        ),
        DistSpec(
            (df, A) -> TuringInverseWishart(df, to_posdef(A)),
            (3.0, A),
            [B, C],
            x -> map(to_posdef, x),
        ),
    ]

    # Tests cannot be executed, so cannot be checked with `@test_broken`.
    broken_matrixvariate_distributions = DistSpec[
        # Other
        # TODO different tests are broken on different combinations of backends
        DistSpec(
            (A, B, C) -> MatrixNormal(A, to_posdef(B), to_posdef(C)),
            (A, B, B),
            C,
            to_posdef,
        ),
        # TODO different tests are broken on different combinations of backends
        DistSpec(
            (df, A, B, C) -> MatrixTDist(df, A, to_posdef(B), to_posdef(C)),
            (1.0, A, B, B),
            C,
            to_posdef,
        ),
        # TODO different tests are broken on different combinations of backends
        DistSpec(
            (n1, n2, A) -> MatrixFDist(n1, n2, to_posdef(A)),
            (3.0, 3.0, A),
            B,
            to_posdef,
        ),
    ]

    @testset "Univariate distributions" begin
        println("\nTesting: Univariate distributions\n")

        for d in univariate_distributions
            @info "Testing: $(nameof(dist_type(d)))"
            test_ad(d)
        end
    end

    @testset "Multivariate distributions" begin
        println("\nTesting: Multivariate distributions\n")

        for d in multivariate_distributions
            @info "Testing: $(nameof(dist_type(d)))"
            test_ad(d)
        end

        # Test `filldist` and `arraydist` distributions of univariate distributions
        n = 2 # always use two distributions
        for d in univariate_distributions
            d.x isa Number || continue

            # Broken distributions
            D = dist_type(d)
            D <: Union{VonMises,TriangularDist} && continue

            # Skellam only fails in these tests with ReverseDiff
            # Ref: https://github.com/TuringLang/DistributionsAD.jl/issues/126
            # PoissonBinomial fails with Zygote
            # Matrix case does not work with Skellam:
            # https://github.com/TuringLang/DistributionsAD.jl/pull/172#issuecomment-853721493
            filldist_broken = if D <: Skellam
                ((d.broken..., :Zygote, :ReverseDiff), (d.broken..., :Zygote, :ReverseDiff))
            elseif D <: PoissonBinomial
                ((d.broken..., :Zygote), (d.broken..., :Zygote))
            elseif D <: Chernoff
                # Zygote is not broken with `filldist`
                ((), ())
            else
                (d.broken, d.broken)
            end
            arraydist_broken = if D <: PoissonBinomial
                ((d.broken..., :Zygote), (d.broken..., :Zygote))
            else
                (d.broken, d.broken)
            end

            # Create `filldist` distribution
            f = d.f
            f_filldist = (θ...,) -> filldist(f(θ...), n)
            d_filldist = f_filldist(d.θ...)

            # Create `arraydist` distribution
            f_arraydist = (θ...,) -> arraydist([f(θ...) for _ in 1:n])
            d_arraydist = f_arraydist(d.θ...)

            for (i, sz) in enumerate(((n,), (n, 2)))
                # Matrix case doesn't work for continuous distributions for some reason
                # now but not too important (?!)
                if length(sz) == 2 && D <: ContinuousDistribution
                    continue
                end

                # Compute compatible sample
                x = fill(d.x, sz)

                # Test AD
                @info "Testing: filldist($(nameof(D)), $sz)"
                test_ad(
                    DistSpec(
                        f_filldist,
                        d.θ,
                        x,
                        d.xtrans;
                        broken=filldist_broken[i],
                    )
                )

                @info "Testing: arraydist($(nameof(D)), $sz)"
                test_ad(
                    DistSpec(
                        f_arraydist,
                        d.θ,
                        x,
                        d.xtrans;
                        broken=arraydist_broken[i],
                    )
                )
            end
        end
    end

    @testset "Matrixvariate distributions" begin
        println("\nTesting: Matrixvariate distributions\n")

        for d in matrixvariate_distributions
            @info "Testing: $(nameof(dist_type(d)))"
            test_ad(d)
        end

        # Test `filldist` and `arraydist` distributions of univariate distributions
        n = (2, 2) # always use 2 x 2 distributions
        for d in univariate_distributions
            d.x isa Number || continue
            D = dist_type(d)
            D <: DiscreteDistribution && continue

            # Broken distributions
            D <: Union{VonMises,TriangularDist} && continue

            # Create `filldist` distribution
            f = d.f
            f_filldist = (θ...,) -> filldist(f(θ...), n...)

            # Create `arraydist` distribution
            # Zygote's fill definition does not like non-numbers, so we use a workaround
            f_arraydist = (θ...,) -> arraydist(reshape([f(θ...) for _ in 1:prod(n)], n))

            # Matrix `x`
            x_mat = fill(d.x, n)

            # Zygote is not broken with `filldist` + Chernoff
            filldist_broken = D <: Chernoff ? () : d.broken

            # Test AD
            @info "Testing: filldist($(nameof(D)), $n)"
            test_ad(
                DistSpec(
                    f_filldist,
                    d.θ,
                    x_mat,
                    d.xtrans;
                    broken=filldist_broken,
                )
            )
            @info "Testing: arraydist($(nameof(D)), $n)"
            test_ad(
                DistSpec(
                    f_arraydist,
                    d.θ,
                    x_mat,
                    d.xtrans;
                    broken=d.broken,
                )
            )

            # Vector of matrices `x`
            x_vec_of_mat = [fill(d.x, n) for _ in 1:2]

            # Test AD
            @info "Testing: filldist($(nameof(D)), $n, 2)"
            test_ad(
                DistSpec(
                    f_filldist,
                    d.θ,
                    x_vec_of_mat,
                    d.xtrans;
                    broken=filldist_broken,
                )
            )
            @info "Testing: arraydist($(nameof(D)), $n, 2)"
            test_ad(
                DistSpec(
                    f_arraydist,
                    d.θ,
                    x_vec_of_mat,
                    d.xtrans;
                    broken=d.broken,
                )
            )
        end

        # test `filldist` and `arraydist` distributions of multivariate distributions
        n = 2 # always use two distributions
        for d in multivariate_distributions
            d.x isa AbstractVector || continue
            D = dist_type(d)
            D <: DiscreteDistribution && continue

            # Tests are failing for matrix covariance vectorized MvNormal
            if D <: Union{
                MvNormal,MvLogNormal,
                DistributionsAD.TuringDenseMvNormal,
                DistributionsAD.TuringDiagMvNormal,
                DistributionsAD.TuringScalMvNormal,
                TuringMvLogNormal
            }
                any(x isa Matrix for x in d.θ) && continue
            end

            # Create `filldist` distribution
            f = d.f
            f_filldist = (θ...,) -> filldist(f(θ...), n)

            # Create `arraydist` distribution
            f_arraydist = (θ...,) -> arraydist([f(θ...) for _ in 1:n])

            # Matrix `x`
            x_mat = repeat(d.x, 1, n)

            # Test AD
            @info "Testing: filldist($(nameof(D)), $n)"
            test_ad(
                DistSpec(
                    f_filldist,
                    d.θ,
                    x_mat,
                    d.xtrans;
                    broken=d.broken,
                )
            )
            @info "Testing: arraydist($(nameof(D)), $n)"
            test_ad(
                DistSpec(
                    f_arraydist,
                    d.θ,
                    x_mat,
                    d.xtrans;
                    broken=d.broken,
                )
            )

            # Vector of matrices `x`
            x_vec_of_mat = [repeat(d.x, 1, n) for _ in 1:2]

            # Test AD
            @info "Testing: filldist($(nameof(D)), $n, 2)"
            test_ad(
                DistSpec(
                    f_filldist,
                    d.θ,
                    x_vec_of_mat,
                    d.xtrans;
                    broken=d.broken,
                )
            )
            @info "Testing: arraydist($(nameof(D)), $n, 2)"
            test_ad(
                DistSpec(
                    f_arraydist,
                    d.θ,
                    x_vec_of_mat,
                    d.xtrans;
                    broken=d.broken,
                )
            )
        end
    end
end
