include("common.jl")

type Equation
	lhs::EX
	rhs::EX
	divisions
end
Equation(ex1::EX,ex2::EX)=Equation(ex1,ex2,Any[]) #or set?
#import Core.is
# ===(a::EX,b::EX)=Equation(a,b)
≖(a::EX,b::EX)=Equation(a,b)
equation(ex::EX)=Equation(ex,0,Any[])
equation(ex1::EX,ex2::EX)=Equation(ex1,ex2,Any[])
==(eq1::Equation,eq2::Equation)=eq1.lhs==eq2.lhs&&eq1.rhs==eq2.rhs
function equivalent(eq1::Equation,eq2::Equation)
	m=matches(eq2)
	for eq in m
		if eq1==eq
			return true
		end
	end
	return false
end
simplify!(eq::Equation)=begin;eq.lhs=simplify!(eq.lhs);eq.rhs=simplify!(eq.rhs);eq;end #the ! functions are not complete
simplify(eq::Equation)=Equation(simplify(eq.lhs),simplify(eq.rhs))
function simplify!(eqa::Array{Equation})
	for eq in 1:length(eqa)
		eqa[eq]=simplify(eqa[eq])
	end
	return eqa
end
simplify(eqa::Array{Equation})=simplify!(deepcopy(eqa))
relations=Equation[]
#eq1=Equation(cos(:x)-sin(:x+pi/2),0)
function pushallunique!(a1::Array,a2::Array)
	for d in a2
		if !(d∈a1)
			push!(a1,d)
		end
	end
	return a1
end
pushallunique!(a1::Array,b::Bool)=Nothing
include("matchers.jl")
matchfuns=Function[]
push!(matchfuns,quadratic)
function matches(eq::Equation)
	m=Equation[]
	if eq.lhs==0
		return m #it only moves from left to right
	end
	eq=simplify(eq)
	terms=addparse(eq.lhs)
	for term in 1:length(terms)
		teq=deepcopy(eq)
		tt=deepcopy(terms)
		if typeof(teq.rhs)==Expression
			push!(teq.rhs,:+)
			push!(teq.rhs,-1)
			for fac in terms[term]
				push!(teq.rhs,fac)
			end
		else
			teq.rhs=Expression([teq.rhs,:+,-1,terms[term]])
		end
		deleteat!(tt,term)
		teq.lhs=expression(tt)
		push!(m,teq)
		if teq.lhs!=0
			dmt=matches(teq,Div)
			for d in dmt
				push!(m,d)
			end
		end
		tm=matches(teq)
		if tm!=false
			for tteq in tm
				if !(tteq∈m)
					push!(m,tteq)
				end
			end
		end
	end
	for teq in m
		teq.rhs=sumnum(componify(teq.rhs))
		teq.lhs=sumnum(componify(teq.lhs))
	end
	return m
end
matches(ex::EX)=matches(equation(ex))
function matches(eq::Equation,fun::Function)
	m=Equation[]
	pushallunique!(m,fun(eq))
	return m
end
matches(ex::EX,fun::Function)=matches(equation(ex),fun)
function matches(eq::Equation,all::Bool)
	if eq.lhs==0
		return false #it only moves from left to right
	end
	eq=simplify(eq)
	m=Equation[]
	for fun in matchfuns
		pushallunique!(m,fun(eq))
	end
	pushallunique!(m,matches(eq,Div))
	pushallunique!(m,matches(eq,Sqrt))
	pushallunique!(m,matches(eq))	
	return m
end
matches(ex::EX,all::Bool)=matches(equation(ex),all)
function matches(eq::Equation,op)
	warn("matches(eq::Equation,op) is deprecated.")
	if op==Div
		lhs=addparse(eq.lhs)
		rhs=addparse(eq.rhs)
		m=Equation[]
		for term in lhs
			for fac in term
				nl=deepcopy(lhs)
				nr=deepcopy(rhs)
				for t in nl
					push!(t,Div(deepcopy(fac)))
				end
				for t in nr
					push!(t,Div(deepcopy(fac)))
				end
				nl=simplify(expression(nl))
				nr=simplify(expression(nr))
				teq=Equation(nl,nr,Any[fac])
				if !(teq∈m)&&!(isa(nl,Number)&&isa(nr,Number)&&nl!=nr) #prevents 1=0 from x=0
					push!(m,teq)
				end
			end
		end
		return m
	elseif op==Sqrt
		lhs=deepcopy(eq.lhs)
		rhs=deepcopy(eq.rhs)
		m=Equation[]
		push!(m,Equation(Sqrt(lhs),Sqrt(rhs)))
		push!(m,Equation(Sqrt(lhs),-Sqrt(rhs)))
		return simplify(m)
	elseif op==Function
		m=Equation[]
		for fun in matchfuns
			pushallunique!(m,simplify(fun(eq)))
		end
		return m
	end
end
matches(ex::EX,op)=matches(equation(ex),op)
function matches(eqa::Array{Equation})
	neqa=deepcopy(eqa)
	for eq in eqa
		m=matches(eq)
		for teq in m
			push!(neqa,teq)
		end
	end
	return neqa
end
function matches!(eqa::Array{Equation})
	leqa=length(eqa)
	for eq in 1:leqa
		m=matches(eqa[eq])
		for teq in m
			if teq!=false&&indin(eqa,teq)==0
				push!(eqa,teq)
			end
		end
	end
	return eqa
end
function matches(eq::Equation,recursions::Integer)
	m=matches(eq)
	for r in 1:recursions
		matches!(m)
	end
	return m
end
matches(ex::EX,rec::Integer)=matches(equation(ex),rec)
include("div.jl")
include("sqrt.jl")
include("pow.jl")
include("der.jl")
function evaluate(eq::Equation,symdic::Dict)
	for key in keys(symdic)
		if symdic[key]==0&&key∈eq.divisions
			error("Assigning zero to a value that the equation has been divided by.")
		end
	end
	return (evaluate(eq.lhs,symdic),evaluate(eq.rhs,symdic))
end
function solve(eq::Equation,rec::Integer=1)
	seq=simplify(eq)
	mat=matches(seq,rec)
	sol=Equation[]
	for m in mat
		if isa(m.lhs,Symbol)
			push!(sol,m)
		end
	end
	return sol
end
function solve(eq::Equation,op)
	seq=simplify(eq)
	mat=matches(seq,op)
	sol=Equation[]
	for m in mat
		if length(addparse(m.lhs))==1
			push!(sol,m)
		end
	end
	return sol
end
solve(ex::Ex)=solve(equation(ex))
solve(ex::Ex,a)=solve(equation(ex),a)
