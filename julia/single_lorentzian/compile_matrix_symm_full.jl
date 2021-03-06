# This is the real version of the calculation based on 8/18/16 notes.

function compile_matrix_symm_full(alpha,beta_real,beta_imag,w,t,y)

# The vectors are arranged as:
# [x_k {{r^R_{k+1,i},r^I_{k+1,i}},i=1..p} {{l^R_{k+1,i},l^I_{k+1,i},i=1..p} x_{k+1} ...]
# For a total of (N-1)*(4(p-p0)+2p0+1)+1 = N(4(p-p0)+2p0+1)-4p equations.
# The equations are arranged as:
# 1). Equation 61 (real only; one single equation);
# 2). Equation 60 (real & imaginary; i=1..p);
# 3). Equation 59 (real & imagingary; i=1..p).

n = length(t)
p = length(alpha)
czero = zero(eltype(alpha))
p0 = 0
for i=1:p
  if beta_imag[i] == czero
    p0 += 1
  end
end
nex = (n-1)*(4(p-p0)+2p0+1)+1
aex = zeros(eltype(alpha),nex,nex)
aex_factor = fill("",nex,nex)
aex_color = fill("",nex,nex)
# First compile bex:
bex = zeros(eltype(alpha),nex)
# Make a string array to hold the variables:
variables = fill("",nex)
variables[1] = " x_1/2"
bex[1] = y[1]/2.0
for k=2:n
  for j=1:p0
    variables[(k-2)*(4(p-p0)+2p0+1)+1+j] = string(" r^R_{",k,",",j,"}")
  end
  for j=(p0+1):p
    variables[(k-2)*(4(p-p0)+2p0+1)+1+p0+(j-p0-1)*2+1] = string(" r^R_{",k,",",j,"}")
    variables[(k-2)*(4(p-p0)+2p0+1)+1+p0+(j-p0-1)*2+2] = string(" r^I_{",k,",",j,"}")
  end
  for j=1:p0
    variables[(k-2)*(4(p-p0)+2p0+1)+1+2p-p0+j] = string(" l^R_{",k,",",j,"}")
  end
  for j=(p0+1):p
    variables[(k-2)*(4(p-p0)+2p0+1)+1+2p+(j-p0-1)*2+1] = string(" l^R_{",k,",",j,"}")
    variables[(k-2)*(4(p-p0)+2p0+1)+1+2p+(j-p0-1)*2+2] = string(" l^I_{",k,",",j,"}")
  end
  variables[(k-1)*(4(p-p0)+2p0+1)+1] = string(" x_",k)
  bex[(k-1)*(4(p-p0)+2p0+1)+1] = y[k]/2.0
end
#for k=1:nex
#  println(k," ",variables[k])
#end
#read(STDIN,Char)

# Do the first row, eqn (61), which is a special case since l_1 = 0:
irow = 1
k = 1
d = sum(alpha)+w
jcol = 1
# Factor multiplying x_1:
aex[jcol,irow]= d/2.0
aex_factor[jcol,irow] = " d/2 "
aex_color[jcol,irow] = " red"
# Compile aex_factor & variables to get equations:
equations = fill("",nex)
equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
one_type = one(eltype(alpha))
gamma_real = zeros(eltype(alpha),p)
gamma_imag = zeros(eltype(alpha),p)
ebt = czero
phi = czero
for j=1:p0
  ebt = exp(-beta_real[j]*(t[k+1]-t[k]))
  gamma_real[j] =  ebt*cos(phi)
# Factor multiplying r^R_{2,j}:
  jcol = 1+j
  aex[jcol,irow]= gamma_real[j]
  aex_factor[jcol,irow] = string(" +gamma^R_{1,",j,"} ")
  aex_color[jcol,irow] = "yellow"
  equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
end
for j=(p0+1):p
  ebt = exp(-beta_real[j]*(t[k+1]-t[k]))
  phi = beta_imag[j]*(t[k+1]-t[k])
  gamma_real[j] =  ebt*cos(phi)
  gamma_imag[j] = -ebt*sin(phi)
# Factor multiplying r^R_{2,j}:
  jcol = 1+p0+(j-p0-1)*2+1
  aex[jcol,irow]= gamma_real[j]
  aex_factor[jcol,irow] = string(" +gamma^R_{1,",j,"} ")
  aex_color[jcol,irow] = "yellow"
  equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
# Factor multiplying r^I_{2,j}:
  jcol = 1+p0+(j-p0-1)*2+2
  aex[jcol,irow]= gamma_imag[j]
  aex_factor[jcol,irow] = string(" +gamma^I_{1,",j,"} ")
  aex_color[jcol,irow] = "orange"
  equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
end
equations[irow] = string(equations[irow]," = b_1/2")
#println(irow,equations[irow])
#read(STDIN,Char)
gamma_real_km1=copy(gamma_real)
gamma_imag_km1=copy(gamma_imag)
# Now, loop over the middle part of the matrix
for k=2:n
  if k < n
    for j=1:p
      ebt = exp(-beta_real[j]*(t[k+1]-t[k]))
      phi = beta_imag[j]*(t[k+1]-t[k])
      gamma_real[j] =  ebt*cos(phi)
      gamma_imag[j] = -ebt*sin(phi)
    end
  end
  for j=1:p0
# Real part of equation (60):
    irow = (k-2)*(4(p-p0)+2p0+1) + 1 + j
# Factors multiplying (l^R_{k,j})
    if k > 2
      jcol = (k-3)*(4(p-p0)+2p0+1) + 1 +2p-p0 + j
      aex[jcol,irow] = gamma_real_km1[j]
      aex_factor[jcol,irow] = string(" +gamma^R_{",k-1,",",j,"} ")
      aex_color[jcol,irow] = "yellow"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
    end
# Factor multiply x_k:
    jcol = (k-2)*(4(p-p0)+2p0+1) + 1
    aex[jcol,irow] = gamma_real_km1[j]
    aex_factor[jcol,irow] = string(" +gamma^R_{",k-1,",",j,"} ")
    aex_color[jcol,irow] = "yellow"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
# Factor multipling l^R_{k+1,j}:
    jcol = (k-2)*(4(p-p0)+2p0+1) + 1 +2p-p0 + j
    aex[jcol,irow] = -one_type
    aex_factor[jcol,irow] = string(" - 1 ")
    aex_color[jcol,irow] = "green"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol]," = 0 ")
#    println(irow,equations[irow])
#    read(STDIN,Char)
# Real part of equation (59):
    irow = (k-2)*(4(p-p0)+2p0+1) + 1 + 2p-p0 + j
# Factor multiplying r^R_{k,j}:
    jcol = (k-2)*(4(p-p0)+2p0+1) + 1 + j
    aex[jcol,irow] = -one_type
    aex_factor[jcol,irow] = string(" - 1 ")
    aex_color[jcol,irow] = "green"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
# Factor multiplying x_k:
    jcol = (k-1)*(4(p-p0)+2p0+1) + 1
    aex[jcol,irow] = 0.5*alpha[j]
    aex_factor[jcol,irow] = string(" + alpha_{",j,"}/2 ")
    aex_color[jcol,irow] = "violet"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
# Factor multiplying r^R_{k+1,j}:
    if k < n
      jcol = (k-1)*(4(p-p0)+2p0+1) + 1 + j
      aex[jcol,irow] = gamma_real[j]
      aex_factor[jcol,irow] = string(" +gamma^R_{",k,",",j,"} ")
      aex_color[jcol,irow] = "yellow"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
    end
    equations[irow] = string(equations[irow]," = 0 ")
#    println(irow,equations[irow])
#    read(STDIN,Char)
  end
  for j=(p0+1):p
# Real part of equation (60):
    irow = (k-2)*(4(p-p0)+2p0+1) + 1 + p0 + (j-p0-1)*2 + 1
# Factors multiplying (l^R_{k,j},l^I_{k,j})
    if k > 2
      jcol = (k-3)*(4(p-p0)+2p0+1) + 1 + 2p-p0 + p0 + (j-p0-1)*2 + 1
      aex[jcol,irow] = gamma_real_km1[j]
      aex_factor[jcol,irow] = string(" +gamma^R_{",k-1,",",j,"} ")
      aex_color[jcol,irow] = "yellow"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
      jcol = (k-3)*(4(p-p0)+2p0+1) + 1 + 2p-p0 + p0 + (j-p0-1)*2 + 2
      aex[jcol,irow] = gamma_imag_km1[j]
      aex_factor[jcol,irow] = string(" +gamma^I_{",k-1,",",j,"} ")
      aex_color[jcol,irow] = "orange"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
    end
# Factor multiply x_k:
    jcol = (k-2)*(4(p-p0)+2p0+1) + 1
    aex[jcol,irow] = gamma_real_km1[j]
    aex_factor[jcol,irow] = string(" +gamma^R_{",k-1,",",j,"} ")
    aex_color[jcol,irow] = "yellow"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
# Factor multipling l^R_{k+1,j}:
    jcol = (k-2)*(4(p-p0)+2p0+1) + 1 + 2p-p0 + p0 + (j-p0-1)*2 +1
    aex[jcol,irow] = -one_type
    aex_factor[jcol,irow] = string(" - 1 ")
    aex_color[jcol,irow] = "green"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol]," = 0 ")
#    println(irow,equations[irow])
#    read(STDIN,Char)
# Imaginary part of equation (60):
    irow = (k-2)*(4(p-p0)+2p0+1) + 1 + p0 + (j-p0-1)*2 + 2
# Factors multiplying (l^R_{k,j},l^I_{k,j}):
    if k > 2
      jcol = (k-3)*(4(p-p0)+2p0+1) + 1 + 2p-p0 + p0 + (j-p0-1)*2 + 1
      aex[jcol,irow] =  gamma_imag_km1[j]
      aex_factor[jcol,irow] = string(" +gamma^I_{",k-1,",",j,"} ")
      aex_color[jcol,irow] = "orange"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
      jcol = (k-3)*(4(p-p0)+2p0+1) + 1 + 2p-p0 + p0 +  (j-p0-1)*2 + 2
      aex[jcol,irow] = -gamma_real_km1[j]
      aex_factor[jcol,irow] = string(" -gamma^R_{",k-1,",",j,"} ")
      aex_color[jcol,irow] = "cyan"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
    end
# Factor multiply x_k:
    jcol = (k-2)*(4(p-p0)+2p0+1) + 1
    aex[jcol,irow] = gamma_imag_km1[j]
    aex_factor[jcol,irow] = string(" +gamma^I_{",k-1,",",j,"} ")
    aex_color[jcol,irow] = "orange"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
# Factor multiplying l^I_{k+1,j}:
    jcol = (k-2)*(4(p-p0)+2p0+1) + 1 + 2p-p0 + p0 + (j-p0-1)*2 + 2
    aex[jcol,irow] =  one_type
    aex_factor[jcol,irow] = string(" + 1 ")
    aex_color[jcol,irow] = "blue"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol]," = 0 ")
#    println(irow,equations[irow])
#    read(STDIN,Char)
# Real part of equation (59):
    irow = (k-2)*(4(p-p0)+2p0+1) + 1 + 2p-p0 + p0 + (j-p0-1)*2 + 1
# Factor multiplying r^R_{k,j}:
    jcol = (k-2)*(4(p-p0)+2p0+1) + 1 + p0 + (j-p0-1)*2 + 1
    aex[jcol,irow] = -one_type
    aex_factor[jcol,irow] = string(" - 1 ")
    aex_color[jcol,irow] = "green"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
# Factor multiplying x_k:
    jcol = (k-1)*(4(p-p0)+2p0+1) + 1
    aex[jcol,irow] = 0.5*alpha[j]
    aex_factor[jcol,irow] = string(" + alpha_{",j,"}/2 ")
    aex_color[jcol,irow] = "violet"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
# Factor multiplying r^R_{k+1,j}:
    if k < n
      jcol = (k-1)*(4(p-p0)+2p0+1) + 1 + p0 + (j-p0-1)*2 + 1
      aex[jcol,irow] = gamma_real[j]
      aex_factor[jcol,irow] = string(" +gamma^R_{",k,",",j,"} ")
      aex_color[jcol,irow] = "yellow"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
# Factor multiplying r^I_{k+1,j}:
      jcol = (k-1)*(4(p-p0)+2p0+1) + 1 + p0 + (j-p0-1)*2 + 2
      aex[jcol,irow] =  gamma_imag[j]
      aex_factor[jcol,irow] = string(" +gamma^I_{",k,",",j,"} ")
      aex_color[jcol,irow] = "orange"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
    end
    equations[irow] = string(equations[irow]," = 0 ")
#    println(irow,equations[irow])
#    read(STDIN,Char)
# Imaginary part of equation (59):
    irow = (k-2)*(4(p-p0)+2p0+1) + 1 + 2p-p0 + p0 + (j-p0-1)*2 + 2
# Factor multiplying r^I_{k,j}:
    jcol = (k-2)*(4(p-p0)+2p0+1) + 1 + p0 + (j-p0-1)*2 + 2
    aex[jcol,irow] =  one_type
    aex_factor[jcol,irow] = string(" + 1")
    aex_color[jcol,irow] = "blue"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
# Factor multiplying r^R_{k+1,j}:
    if k < n
      jcol = (k-1)*(4(p-p0)+2p0+1) + 1 + p0 + (j-p0-1)*2 + 1
      aex[jcol,irow] = gamma_imag[j]
      aex_factor[jcol,irow] = string(" +gamma^I_{",k,",",j,"} ")
      aex_color[jcol,irow] = "orange"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
# Factor multiplying r^I_{k+1,j}:
      jcol = (k-1)*(4(p-p0)+2p0+1) + 1 + p0 + (j-p0-1)*2 + 2
      aex[jcol,irow] = -gamma_real[j]
      aex_factor[jcol,irow] = string(" -gamma^R_{",k,",",j,"} ")
      aex_color[jcol,irow] = "cyan"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
    end
    equations[irow] = string(equations[irow]," = 0 ")
  end
#  println(irow,equations[irow])
#  read(STDIN,Char)
# Equation (61), only real:
  irow = (k-1)*(4(p-p0)+2p0+1) + 1
# Factor multiplying x_k:
  jcol = (k-1)*(4(p-p0)+2p0+1) + 1
  aex[jcol,irow] = d/2.0
  aex_factor[jcol,irow] = string(" +d/2 ")
  aex_color[jcol,irow] = "red"
  equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
  for j=1:p0
# Factor multiplying l^R_{k,j}:
    jcol = (k-2)*(4(p-p0)+2p0+1) + 1 + 2p-p0 + j
    aex[jcol,irow] =  alpha[j]/2.0
    aex_factor[jcol,irow] = string(" +alpha_{",j,"}/2 ")
    aex_color[jcol,irow] = "violet"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
    if k < n
# Factor multiplying r^R_{k+1,j}:
      jcol = (k-1)*(4(p-p0)+2p0+1) + 1 + j
      aex[jcol,irow]=  gamma_real[j]
      aex_factor[jcol,irow] = string(" +gamma^R_{",k,",",j,"} ")
      aex_color[jcol,irow] = "yellow"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
    end
  end
  for j=(p0+1):p
# Factor multiplying l^R_{k,j}:
    jcol = (k-2)*(4(p-p0)+2p0+1) + 1 + 2p-p0 + p0+ (j-p0-1)*2 + 1
    aex[jcol,irow] =  alpha[j]/2.0
    aex_factor[jcol,irow] = string(" +alpha_{",j,"}/2 ")
    aex_color[jcol,irow] = "violet"
    equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
    if k < n
# Factor multiplying r^R_{k+1,j}:
      jcol = (k-1)*(4(p-p0)+2p0+1) + 1 + p0 + (j-p0-1)*2 + 1
      aex[jcol,irow]=  gamma_real[j]
      aex_factor[jcol,irow] = string(" +gamma^R_{",k,",",j,"} ")
      aex_color[jcol,irow] = "yellow"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
# Factor multiplying r^I_{k+1,j}:
      jcol = (k-1)*(4(p-p0)+2p0+1) + 1 + p0 + (j-p0-1)*2 + 2
      aex[jcol,irow]=  gamma_imag[j]
      aex_factor[jcol,irow] = string(" +gamma^I_{",k,",",j,"} ")
      aex_color[jcol,irow] = "orange"
      equations[irow] = string(equations[irow],aex_factor[jcol,irow],variables[jcol])
    end
  end
  equations[irow] = string(equations[irow]," = b_",k,"/2")
#  println(irow,equations[irow])
#  read(STDIN,Char)
  for j=1:p
    gamma_real_km1[j]=gamma_real[j]
    gamma_imag_km1[j]=gamma_imag[j]
  end
end
return aex,bex,equations,variables,aex_factor,aex_color
end
