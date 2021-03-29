@testset "Definition forms" begin
   T,t = PolynomialRing(FiniteField(3),"t")
   F,z = FiniteField(t^2+1,"z")

   B = matrix(F,4,4,[0 1 0 0; 2 0 0 0; 0 0 0 z+2; 0 0 1-z 0])
   @test isskewsymmetric_matrix(B)
   f = alternating_form(B)
   @test f isa SesquilinearForm
   @test gram_matrix(f)==B
   @test f==alternating_form(gram_matrix(f))
   @test base_ring(B)==F
   @test !issymmetric(B)
   @test !ishermitian_matrix(B)
   @test isalternating_form(f)
   @test !isquadratic_form(f)
   @test !issymmetric_form(f)
   @test !ishermitian_form(f)
   @test_throws AssertionError f = symmetric_form(B)
   @test_throws AssertionError f = hermitian_form(B)

   B = matrix(F,4,4,[0 1 0 0; 1 0 0 0; 0 0 0 z+2; 0 0 -1-z 0])
   @test ishermitian_matrix(B)
   f = hermitian_form(B)
   @test f isa SesquilinearForm
   @test gram_matrix(f)==B
   @test ishermitian_form(f)
   @test f.mat_iso isa Oscar.GenMatIso
   @test f.X isa GapObj
   @test_throws AssertionError f = symmetric_form(B)
   @test_throws AssertionError f = alternating_form(B)
   @test_throws ArgumentError corresponding_quadratic_form(f)
   @test_throws ErrorException f = SesquilinearForm(B,:unitary)

   B = matrix(F,4,4,[0 1 0 0; 1 0 0 0; 0 0 0 z+2; 0 0 z+2 0])
   @test issymmetric(B)
   f = symmetric_form(B)
   @test f isa SesquilinearForm
   @test gram_matrix(f)==B
   @test issymmetric_form(f)
   @test !ishermitian_form(f)
   @test_throws AssertionError f = alternating_form(B)
   Qf = corresponding_quadratic_form(f)
   R = PolynomialRing(F,4)[1]
   p = R[1]*R[2]+(z+2)*R[3]*R[4]
   Q = quadratic_form(p)
   @test Q==Qf
   @test corresponding_quadratic_form(corresponding_bilinear_form(Q))==Q
   @test corresponding_bilinear_form(Q)==f
   B1 = matrix(F,4,4,[0 0 0 0; 1 0 0 0; 0 0 0 0; 0 0 z+2 0])
   Q1 = quadratic_form(B1)
   @test Q1==Q
   @test gram_matrix(Q1)!=B1
   @test defining_polynomial(Q1) isa AbstractAlgebra.Generic.MPolyElem
   pf = defining_polynomial(Q1)
   @test defining_polynomial(Q1)==parent(pf)[1]*parent(pf)[2]+(z+2)*parent(pf)[3]*parent(pf)[4]
# I can't test simply pf==p, because it returns FALSE. The line
 #      PolynomialRing(F,4)[1]==PolynomialRing(F,4)[1]
# returns FALSE.
   @test_throws ArgumentError corresponding_quadratic_form(Q)
   @test_throws ArgumentError corresponding_bilinear_form(f)

   R,x = PolynomialRing(F,"x")
   p = x^2*z
   Q = quadratic_form(p)
   @test isquadratic_form(Q)
   f = corresponding_bilinear_form(Q)
   @test issymmetric_form(f)
   @test gram_matrix(f)==matrix(F,1,1,[-z])

   T,t = PolynomialRing(FiniteField(2),"t")
   F,z = FiniteField(t^2+t+1,"z")
   R = PolynomialRing(F,4)[1]
   p = R[1]*R[2]+z*R[3]*R[4]
   Q = quadratic_form(p)
   @test isquadratic_form(Q)
   @test gram_matrix(Q)==matrix(F,4,4,[0 1 0 0; 0 0 0 0; 0 0 0 z; 0 0 0 0])
   f = corresponding_bilinear_form(Q)
   @test isalternating_form(f)
   @test gram_matrix(f)==matrix(F,4,4,[0 1 0 0; 1 0 0 0; 0 0 0 z; 0 0 z 0])
   @test_throws ArgumentError corresponding_quadratic_form(f)


end

@testset "Evaluating forms" begin
   F,z=GF(3,2,"z")
   V=VectorSpace(F,6)

   x = matrix(F,6,6,[1,0,0,0,z+1,0,0,0,0,2,1+2*z,1,0,0,1,0,0,z,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,1])
   f = alternating_form(x-transpose(x))
   for i in 1:6
   for j in i:6
      @test f(V[i],V[j])==f.matrix[i,j]
   end
   end

   f = hermitian_form(x+conjugate_transpose(x))
   for i in 1:6
   for j in i:6
      @test f(V[i],V[j])==f(V[j],V[i])^3         # x -> x^3 is the field automorphism
   end
   end

   Q = quadratic_form(x)
   f = corresponding_bilinear_form(Q)
   @test f.matrix==x+transpose(x)
   for i in 1:6
   for j in i:6
      @test f(V[i],V[j])==Q(V[i]+V[j])-Q(V[i])-Q(V[j])
   end
   end

   @test_throws AssertionError Q(V[1],V[5])
   @test_throws AssertionError f(V[2])

   g = rand(GL(6,F))
   v = rand(V)
   w = rand(V)
   @test (f^g)(v,w)==f(v*g^-1,w*g^-1)
   @test (Q^g)(v)==Q(v*g^-1)
end

@testset "Methods with forms" begin
   F = GF(5,1)[1]
   V = VectorSpace(F,6)
   x = zero_matrix(F,6,6)
   f = symmetric_form(x)
   @test radical(f)[1]==sub(V,gens(V))[1]
   x[3,5]=1; x[4,6]=1;
   f = symmetric_form(x+transpose(x))
   @test radical(f)[1]==sub(V,[V[1],V[2]])[1]
   @test f*F(3)==F(3)*f;
   @test issymmetric_form(f*F(3))
   @test gram_matrix(f*F(3))==F(3)*(x+transpose(x))
   @test isdegenerate(f)
   x[1,2]=1;

   f = symmetric_form(x+transpose(x))
   @test radical(f)[1]==sub(V,[])[1]
   Q = corresponding_quadratic_form(f)
   @test radical(Q)[1]==radical(f)[1]
   @test witt_index(f)==3
   @test witt_index(Q)==3
   @test !isdegenerate(f)

   F = GF(2,1)[1]
   x = matrix(F,2,2,[1,0,0,0])
   Q = quadratic_form(x)
   @test dim(radical(Q)[1])==1
   f = corresponding_bilinear_form(Q)
   @test dim(radical(f)[1])==2

end

@testset "TransformForm" begin
   # symmetric
   F = GF(3,1)[1]
   x = zero_matrix(F,6,6)
   x[4,5]=1; x[5,6]=1; x=x+transpose(x)
   y = zero_matrix(F,6,6)
   y[1,3]=2;y[3,4]=1; y=y+transpose(y)
   f = symmetric_form(x); g = symmetric_form(y)
   is_true,z = iscongruent(f,g)
   @test is_true
   @test f^z == g

   F = GF(7,1)[1]
   x = diagonal_matrix(F.([1,4,2,3,6,5,4]))
   y = diagonal_matrix(F.([3,1,5,6,4,2,1]))
   f = symmetric_form(x); g = symmetric_form(y)
   is_true,z = iscongruent(f,g)
   @test is_true
   @test f^z == g
   y = diagonal_matrix(F.([3,1,5,6,4,3,1]))
   f = symmetric_form(x); g = symmetric_form(y)
   is_true,z = iscongruent(f,g)
   @test !is_true
   @test z==nothing

   T,t = PolynomialRing(FiniteField(3),"t")
   F,a = FiniteField(t^2+1,"a")
   x = zero_matrix(F,6,6)
   x[1,2]=1+2*a; x[3,4]=a; x[5,6]=1; x=x+transpose(x)
   y = diagonal_matrix(F.([a,1,1,a+1,2,2*a+2]))
   f = symmetric_form(x); g = symmetric_form(y)
   is_true,z = iscongruent(f,g)
   @test is_true
   @test f^z == g
   y = diagonal_matrix(F.([a,1,1,a+1,2,2*a]))
   g = symmetric_form(y)
   is_true,z = iscongruent(f,g)
   @test !is_true


   #alternating
   F = GF(3,1)[1]
   x = zero_matrix(F,6,6)
   x[4,5]=1; x[5,6]=1; x=x-transpose(x)
   y = zero_matrix(F,6,6)
   y[1,3]=2;y[3,4]=1; y=y-transpose(y)
   f = alternating_form(x); g = alternating_form(y)
   is_true,z = iscongruent(f,g)
   @test is_true
   @test f^z == g

   F,a = GF(2,3,"a")
   x = zero_matrix(F,6,6)
   x[1,2]=a; x[2,3]=a^2+1; x[3,4]=1; x[1,5]=a^2+a+1; x[5,6]=1; x=x-transpose(x)
   y = zero_matrix(F,6,6)
   y[1,6]=1; y[2,5]=a; y[3,4]=a^2+1; y = y-transpose(y)
   f = alternating_form(x); g = alternating_form(y)
   is_true,z = iscongruent(f,g)
   @test is_true
   @test f^z == g
   x = zero_matrix(F,8,8)
   x[1,2]=a; x[2,3]=a^2-1; x[3,4]=1; x[1,5]=a^2-a-1; x[5,6]=1; x[7,8]=-1; x=x-transpose(x)
   y = zero_matrix(F,8,8)
   y[1,8]=1; y[2,7]=a; y[3,6]=a^2+1; y[4,5] = -a^2-a-1; y = y-transpose(y)
   f = alternating_form(x); g = alternating_form(y)
   is_true,z = iscongruent(f,g)
   @test is_true
   @test f^z == g
   y = zero_matrix(F,8,8)
   y[1,8]=1; y[2,7]=a; y[3,6]=a^2+1; y = y-transpose(y)
   f = alternating_form(x); g = alternating_form(y)
   is_true,z = iscongruent(f,g)
   @test !is_true

   y = zero_matrix(F,6,6)
   y[1,6]=1; y[2,5]=a; y[3,4]=a^2+1; y = y-transpose(y)
   g = alternating_form(y)
   @test_throws AssertionError iscongruent(f,g)

   F = GF(3,1)[1]
   y = zero_matrix(F,8,8)
   y[1,3]=2;y[3,4]=1; y=y-transpose(y)
   g = alternating_form(y)
   @test_throws AssertionError iscongruent(f,g)

   #hermitian
   F,a = GF(3,2,"a")
   x = zero_matrix(F,6,6)
   x[4,5]=1; x[5,6]=a-1; x=x+conjugate_transpose(x)
   y = zero_matrix(F,6,6)
   y[1,2]=2; y=y+conjugate_transpose(y)
   f = hermitian_form(x); g = hermitian_form(y)
   is_true,z = iscongruent(f,g)
   @test is_true
   @test f^z == g
   x = diagonal_matrix(F.([1,2,1,1,1]))
   y = diagonal_matrix(F.([2,1,0,0,2]))
   y[3,4]=a; y[4,3]=a^3; y[4,5]=1+a; y[5,4]=(1+a)^3;
   f = hermitian_form(x); g = hermitian_form(y)
   is_true,z = iscongruent(f,g)
   @test is_true
   @test f^z == g
   F,a = GF(2,2,"a")
   x = zero_matrix(F,6,6)
   x[4,5]=1; x[5,6]=a+1; x=x+conjugate_transpose(x)
   y = zero_matrix(F,6,6)
   y[1,2]=1; y=y+conjugate_transpose(y)
   f = hermitian_form(x); g = hermitian_form(y)
   is_true,z = iscongruent(f,g)
   @test is_true
   @test f^z == g
   x = diagonal_matrix(F.([1,1,1,1,1]))
   y = diagonal_matrix(F.([1,1,0,0,1]))
   y[3,4]=a; y[4,3]=a^2; y[4,5]=1+a; y[5,4]=(1+a)^2;
   f = hermitian_form(x); g = hermitian_form(y)
   is_true,z = iscongruent(f,g)
   @test is_true
   @test f^z == g

   #quadratic
   F = GF(5,1)[1]
   R = PolynomialRing(F,6)[1]
   p1 = R[1]*R[2]
   p2 = R[4]*R[5]+3*R[4]^2
   Q1 = quadratic_form(p1)
   Q2 = quadratic_form(p2)
   is_true,z = iscongruent(Q1,Q2)
   @test is_true
   @test Q1^z == Q2
   p2 = R[4]*R[5]+3*R[4]^2+2*R[5]^2
   Q2 = quadratic_form(p2)
   is_true,z = iscongruent(Q1,Q2)
   @test !is_true

   p1 = R[1]^2+R[2]^2+R[3]^2+R[4]^2+R[5]*R[6]
   p2 = R[1]*R[6]+R[2]*R[5]+R[3]*R[4]
   Q1 = quadratic_form(p1)
   Q2 = quadratic_form(p2)
   is_true,z = iscongruent(Q1,Q2)
   @test is_true
   @test Q1^z == Q2
   p1 = R[1]^2+R[2]^2+R[3]^2+R[4]^2+R[5]^2+R[5]*R[6]+2*R[6]^2
   Q1 = quadratic_form(p1)
   is_true,z = iscongruent(Q1,Q2)
   @test !is_true

   F,a = GF(2,2,"a")
   R = PolynomialRing(F,6)[1]
   p1 = R[1]*R[2]+R[3]*R[4]+R[5]^2+R[5]*R[6]+R[6]^2
   p2 = R[1]*R[6]+a*R[2]*R[5]+R[3]*R[4]
   Q1 = quadratic_form(p1)
   Q2 = quadratic_form(p2)
   is_true,z = iscongruent(Q1,Q2)
   @test is_true
   @test Q1^z == Q2
   p1 = R[1]*R[2]+R[3]*R[4]+R[5]^2+R[5]*R[6]+a*R[6]^2
   Q1 = quadratic_form(p1)
   is_true,z = iscongruent(Q1,Q2)
   @test !is_true
   p1 = R[1]*R[2]
   p2 = R[3]^2+(a+1)*R[3]*R[5]
   Q1 = quadratic_form(p1)
   Q2 = quadratic_form(p2)
   is_true,z = iscongruent(Q1,Q2)
   @test is_true
   @test Q1^z == Q2
   p2 = R[3]^2+R[3]*R[5]+(a+1)*R[5]^2
   Q2 = quadratic_form(p2)
   is_true,z = iscongruent(Q1,Q2)
   @test !is_true
end
