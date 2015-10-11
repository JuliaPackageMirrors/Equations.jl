abstract AbstractTensor<:NonAbelian
type Tensor<:AbstractTensor
	x
	upper
	lower
	rank
end
Tensor(a,b,c)=Tensor(a,b,c,-1)
function print(io::IO,t::Tensor)
	print(io,"$(t.x)($(t.upper),$(t.lower))")
end

type Braket<:Component
	x
	y
end
function print(io::IO,bk::Braket)
	print(io,'⟨')
	print(io,bk.x)
	print(io,'|')
	print(io,bk.y)
	print(io,'⟩')
end

type Delta<:AbstractTensor
	x
	y
end
function simplify(d::Delta)
	if d.x==d.y
		return 1
	elseif isa(d.x,Number)&&isa(d.y,Number)
		return 0
	end
	return d
end
function print(io::IO,d::Delta)
	print(io,"δ($(d.x),$(d.y))")
end

type D<:NonAbelian
	x
end
function print(io::IO,d::D)
	if isa(d.x,X)
		print(io,"d$(d.x)")
	else
		print(io,"d($(d.x))")
	end
end

type TensorProduct <: AbstractTensor
	tensors
end
function ⊗(tp1::TensorProduct,tp2::TensorProduct)
	tp=deepcopy(tp1)
	for t in tp2.tensors
		push!(tp.tensors,t)
	end
	tp
end
⊗(tp::TensorProduct,t)=begin;tp=deepcopy(tp);push!(tp.tensors,t);tp;end
⊗(t,tp::TensorProduct)=begin;tp=deepcopy(tp);unshift!(tp.tensors,t);tp;end
⊗(t1,t2)=TensorProduct([t1,t2])
function print(io::IO,tp::TensorProduct)
	print("$(tp.tensors[1]) ⊗")
	for i in 2:length(tp.tensors)-1
		print(" $(tp.tensors[i]) ⊗")
	end
	print(" $(tp.tensors[end])")
end
type WedgeProduct <: AbstractTensor
	tensors
end
function ∧(tp1::WedgeProduct,tp2::WedgeProduct)
	tp=deepcopy(tp1)
	for t in tp2.tensors
		push!(tp.tensors,t)
	end
	tp
end
∧(tp::WedgeProduct,t)=begin;tp=deepcopy(tp);push!(tp.tensors,t);tp;end
∧(t,tp::WedgeProduct)=begin;tp=deepcopy(tp);unshift!(tp.tensors,t);tp;end
∧(t1,t2)=WedgeProduct([t1,t2])
function print(io::IO,tp::WedgeProduct)
	print("$(tp.tensors[1]) ∧")
	for i in 2:length(tp.tensors)-1
		print(" $(tp.tensors[i]) ∧")
	end
	print(" $(tp.tensors[end])")
end
