using PyPlot
include("lorentz_likelihood_hermitian_band_init.jl")
include("lorentz_likelihood_hermitian_band_save.jl")
include("lorentz_likelihood_hermitian_sparse.jl")
include("lorentz_likelihood_hermitian.jl")
include("bandec.jl")
include("banbks.jl")


# Compute time for Generalized Rybicki-Press with three Lorentzian components
# for benchmarking:

#function time_julia()
omega = 2pi/12.203317
#alpha = [1.0428542, -0.38361831, 0.30345984/2, 0.30345984/2]*1.6467e-7
alpha = [1.0428542, 0.30345984/2, 0.30345984/2]*1.6467e-7
p = length(alpha)
#beta = [complex(0.1229159,0.0),complex(0.48922908,0.0),complex(0.09086397,omega),complex(0.09086397,-omega)]
beta = [complex(0.1229159,0.0),complex(0.09086397,omega),complex(0.09086397,-omega)]
w0 =  0.03027 * 1.6467e-7
nt = [16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288]
nnt = length(nt)
time_compute = zeros(nnt)
time_likelihood = zeros(nnt)
time_sparse = zeros(nnt)
for it=1:nnt
  n = nt[it]
  t = collect(linspace(0,n-1,n))
# White noise component:

# Use white noise for doing the timing test:
  y=randn(n)*sqrt(w0)
  ysave = zeros(n)
  for i=1:n
    ysave[i]=y[i]
  end
# Now use Ambikarasan O(N) method:
  tic()
  aex,al_small,indx,logdeta = lorentz_likelihood_hermitian_band_init(alpha,beta,w0,t)
  time_compute[it] = toq();
  tic()
  log_like = lorentz_likelihood_hermitian_band_save(p,y,aex,al_small,indx,logdeta)
  time_likelihood[it] = toq();
  tic()
  aex_full,bex_full = lorentz_likelihood_hermitian(alpha,beta,w0,t,ysave)
  aex_sparse,bex_sparse = lorentz_likelihood_hermitian_sparse(alpha,beta,w0,t,ysave)
  typeof(aex)
  typeof(bex)
  solution = aex\bex
  log_like_sparse = 0.0
  for i=1:n
    log_like_sparse += real(solution[(i-1)*(2p+1)+1])*ysave[i]
  end
  log_like_sparse = -0.5*(log_like + logdet(aex))
  time_sparse[it] = toq()
  println(n," ",time_compute[it]," ",time_likelihood[it]," ",time_sparse[it])
  println(log_like," ",log_like_sparse)
end
#return
#end
