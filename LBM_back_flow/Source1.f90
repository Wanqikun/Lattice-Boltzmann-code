! computer code for planes
parameter (n=400,m=40)
real f(0:8,0:n,0:m)
real feq(0:8,0:n,0:m),rho(0:n,0:m)
real w(0:8), cx(0:8),cy(0:8)
real u(0:n,0:m), v(0:n,0:m)
integer i
open(2,file='uvfield.plt')
open(3,file='uvely.plt')
open(4,file='vvelx.plt')
open(8,file='timeu.plt')
!
uo=0.20
sumvelo=0.0
rhoo=5.00
dx=1.0
dy=dx
dt=1.0
alpha=0.02
re=uo*m/alpha
print *, "re=", re
omega=1.0/(2.*alpha+0.5)
mstep=40000
w(0)=4./9.
do i=1,4
w(i)=1./9.
end do
do i=5,8
w(i)=1./36.
end do
cx(0)=0
cx(1)=1
cx(2)=0
cx(3)=-1
cx(4)=0
cx(5)=1
cx(6)=-1
cx(7)=-1
cx(8)=1
cy(0)=0
cy(1)=0
cy(2)=1
cy(3)=0
cy(4)=-1
cy(5)=1
cy(6)=1
cy(7)=-1
cy(8)=-1
do j=0,m
do i=0,n
rho(i,j)=rhoo
u(i,j)=0.0
v(i,j)=0.0
end do
end do
!do i=1,n-1
!u(i,m)=uo
!v(i,m)=0.0
!end do
! main loop
do kk=1,mstep
call collesion(u,v,f,feq,rho,omega,w,cx,cy,n,m)
call streaming(f,n,m)
! ���������������������C
call sfbound(f,n,m,uo)
call rhouv(f,rho,u,v,cx,cy,n,m)
print *, u(0,m/2),v(0,m/2),rho(0,m/2),u(n,m/2),v(n,m/2),rho(n,m/2)
write(8,*) kk,u(n/2,m/2),v(n/2,m/2)
end do
! end of the main loop
call result(u,v,rho,uo,n,m)
stop
end
! end of the main program
subroutine collesion(u,v,f,feq,rho,omega,w,cx,cy,n,m)
real f(0:8,0:n,0:m)
real feq(0:8,0:n,0:m),rho(0:n,0:m)
real w(0:8), cx(0:8),cy(0:8)
real u(0:n,0:m), v(0:n,0:m)
do i=0,n
do j=0,m
t1=u(i,j)*u(i,j)+v(i,j)*v(i,j)
do k=0,8
t2=u(i,j)*cx(k)+v(i,j)*cy(k)
feq(k,i,j)=rho(i,j)*w(k)*(1.0+3.0*t2+4.50*t2*t2-1.50*t1)
f(k,i,j)=omega*feq(k,i,j)+(1.-omega)*f(k,i,j)
end do
end do
end do
return
end
subroutine streaming(f,n,m)
real f(0:8,0:n,0:m)
! streaming
do j=0,m
do i=n,1,-1 !right to left
f(1,i,j)=f(1,i-1,j)
end do
do i=0,n-1 !left to right
f(3,i,j)=f(3,i+1,j)
end do
end do
do j=m,1,-1 !top to bottom
do i=0,n
f(2,i,j)=f(2,i,j-1)
end do
do i=n,1,-1
f(5,i,j)=f(5,i-1,j-1)
end do
do i=0,n-1
f(6,i,j)=f(6,i+1,j-1)
end do
end do
do j=0,m-1 !bottom to top
do i=0,n
f(4,i,j)=f(4,i,j+1)
end do
do i=0,n-1
f(7,i,j)=f(7,i+1,j+1)
end do
do i=n,1,-1
f(8,i,j)=f(8,i-1,j+1)
end do
end do
return
end
subroutine sfbound(f,n,m,uo)
real f(0:8,0:n,0:m)
real uo
do j=21,m
! bounce back on west boundary
rhow=(f(0,0,j)+f(2,0,j)+f(4,0,j)+2*(f(3,0,j)+f(6,0,j)+f(7,0,j)))/(1.0-uo)
f(1,0,j)=f(3,0,j)+2*rhow*uo/3.0
f(5,0,j)=f(7,0,j)+rhow*uo/6.0!f(2,0,j)=f(4,0,j)
f(8,0,j)=f(6,0,j)+rhow*uo/6.0
end do
! bounce back on south boundary
do i=0,n
f(2,i,0)=f(4,i,0)
f(5,i,0)=f(7,i,0)
f(6,i,0)=f(8,i,0)
end do
! bounce back on north boundary
do i=0,n
f(4,i,m)=f(2,i,m)
f(8,i,m)=f(6,i,m)
f(7,i,m)=f(5,i,m)
end do
!account for open boundary condition at the outlet
do j=1,m
    f(1,n,j)=2*f(1,n-1,j)-f(1,n-2,j)
    f(5,n,j)=2*f(5,n-1,j)-f(5,n-2,j)
    f(8,n,j)=2*f(8,n-1,j)-f(8,n-2,j)
end do
!obstacle at thee inlet x=40,y=20
do i=0,40
    f(2,i,20)=f(4,i,20)
    f(5,i,20)=f(7,i,20)
    f(6,i,20)=f(8,i,20)
end do
do j=0,20
    f(1,40,j)=f(3,40,j)
    f(5,40,j)=f(7,40,j)
    f(8,40,j)=f(6,40,j)
end do
return
end
subroutine rhouv(f,rho,u,v,cx,cy,n,m)
real f(0:8,0:n,0:m),rho(0:n,0:m),u(0:n,0:m),v(0:n,0:m),cx(0:8),cy(0:8)
do j=0,m
do i=0,n
ssum=0.0
do k=0,8
ssum=ssum+f(k,i,j)
end do
rho(i,j)=ssum
end do
end do
do i=1,n
rho(i,m)=f(0,i,m)+f(1,i,m)+f(3,i,m)+2.*(f(2,i,m)+f(6,i,m)+f(5,i,m))
end do
do i=1,n
do j=1,m-1
usum=0.0
vsum=0.0
do k=0,8
usum=usum+f(k,i,j)*cx(k)
vsum=vsum+f(k,i,j)*cy(k)
end do
u(i,j)=usum/rho(i,j)
v(i,j)=vsum/rho(i,j)
end do
end do
do j=0,m
    v(n,j)=0.0
end do
do j=0,20
    do i=0,40
        u(i,j)=0.0
        v(i,j)=0.0
    end do
end do
return
end
subroutine result(u,v,rho,uo,n,m)
real u(0:n,0:m),v(0:n,0:m)
real rho(0:n,0:m),strf(0:n,0:m)
open(5, file="streamf.plt")
! streamfunction calculations
strf(0,0)=0.0
do i=1,n
rhoav=0.5*(rho(i-1,0)+rho(i,0))
if(i.ne.0) strf(i,0)=strf(i-1,0)-rhoav*0.5*(v(i-1,0)+v(i,0))
do j=1,m
rhom=0.5*(rho(i,j)+rho(i,j-1))
strf(i,j)=strf(i,j-1)+rhom*0.5*(u(i,j-1)+u(i,j))
end do
end do
! �����������������������C
write(2,*)"VARIABLES=X,Y,U,V"
write(2,*)"ZONE ","I=",n+1,",","J=",m+1,",","F=BLOCK"
do j=0,m
write(2,*)(i,i=0,n)
end do
do j=0,m
write(2,*)(j,i=0,n)
end do
do j=0,m
write(2,*)(u(i,j),i=0,n)
end do
do j=0,m
write(2,*)(v(i,j),i=0,n)
end do

write(5,*)"VARIABLES=X,Y,ST"
write(5,*)"ZONE ","I=",n+1,",","J=",m+1,",","F=BLOCK"
do j=0,m
write(5,*)(i,i=0,n)
end do
do j=0,m
write(5,*)(j,i=0,n)    
end do
do j=0,m
write(5,*)(strf(i,j),i=0,n)    
end do

do j=0,m
write(3,*)j/float(m),u(n/2,j)/uo,u(n/4,j)/uo,u(3*n/4,j)/uo
end do
do i=0,n
write(4,*) i/float(n),v(i,m/2)/uo
end do
return
end
!============end of the program