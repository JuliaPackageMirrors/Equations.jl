###Equations
eq=equation(:x)
@test eq==Equation(:x,0)

#evaluate
eq=equation(1/:x-sqrt(:x))
@test evaluate(eq,[:x=>1])==(0,0)
m=matches(eq)
for tm in m
	l,r=evaluate(tm,[:x=>1])
	@test l==r
end

#solve
eq=equation(:x+:z+:t)
sol=solve(eq)
for s in sol
	res=evaluate(eq,[s.lhs=>s.rhs])
	@test res[1]==res[2]
end
