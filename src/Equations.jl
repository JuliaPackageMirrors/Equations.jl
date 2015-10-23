module Equations
#types
export Equation, EquationChain, Expression, Component, NonAbelian, Operator, Ex, Term, Factor, ╱,Div, Sqrt, Pow,Exp,Log, Der,DerOp, Vec,Cross,Dot,Norm, Named,Oneable, Physical, AbstractTensor,Tensor,Braket,Delta,⊗,TensorProduct,∧,Wedge,D,Form,Trace,Commutator
#functions
export equation, solve, expression, ≖, evaluate, simplify, simplify!, componify, componify!, addparse, has, sumnum, sumsym, matches, getarg, findpows, indin, indsin, replace, findsyms, quadratic, complexity, terms, getargs, randeval, expandindices, @equ,@equs
#relations
export relations

include("equations.jl")

end # module
