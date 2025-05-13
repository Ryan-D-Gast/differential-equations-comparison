C     PROGRAM TO SOLVE TWO-BODY PROBLEM USING HAIRER DOP853
      PROGRAM TWOBODYHAIRER
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (N=6)
      DIMENSION Y(N), RTOL(N), ATOL(N), WORK(8000), IWORK(1000)
      DIMENSION RPAR(1), IPAR(1), YANALYTICAL(N)
      EXTERNAL FCN, SOLOUT
      
C     Earth's gravitational parameter (m^3/s^2)
      DOUBLE PRECISION MU
      MU = 3.986004418D14
      RPAR(1) = MU
      
C     Initial orbit parameters (circular orbit at altitude of ~408km - ISS-like orbit)
      EARTH_RADIUS = 6378137.0D0    ! meters
      ORBIT_ALTITUDE = 408000.0D0   ! meters
      ORBIT_RADIUS = EARTH_RADIUS + ORBIT_ALTITUDE
      
C     Calculate orbital velocity for circular orbit
      V_CIRCULAR = DSQRT(MU / ORBIT_RADIUS)
      
C     Initial conditions: starting at (r, 0, 0) with velocity (0, v, 0)
      Y(1) = ORBIT_RADIUS   ! x
      Y(2) = 0.0D0          ! y
      Y(3) = 0.0D0          ! z
      Y(4) = 0.0D0          ! vx
      Y(5) = V_CIRCULAR     ! vy
      Y(6) = 0.0D0          ! vz
      
C     Calculate orbital period
      PI = 3.14159265358979323846D0
      PERIOD = 2.0D0 * PI * DSQRT(ORBIT_RADIUS**3 / MU)
      
C     Simulation for 10 complete orbits
      X = 0.0D0             ! t0 = 0.0
      XEND = 1000.0D0 * PERIOD ! tf = 10 orbital periods
      
C     Set tolerances to match Rust version - PER COMPONENT
      DO 5 I=1,N
         RTOL(I) = 1.0D-12     ! rtol = 1e-12
         ATOL(I) = 1.0D-12     ! atol = 1e-12
5     CONTINUE
      
C     Set method parameters
      ITOL = 1              ! Changed from 0 to 1 for component-wise tolerances
      IOUT = 0
      IDID = 0
      
C     Initialize work arrays
      DO 10 I=1,8000
         WORK(I) = 0.0D0
10    CONTINUE
      DO 20 I=1,1000
         IWORK(I) = 0
20    CONTINUE
      
C     Call the integrator
      CALL DOP853(N, FCN, X, Y, XEND,
     &            RTOL, ATOL, ITOL,
     &            SOLOUT, IOUT,
     &            WORK, 8000, IWORK, 1000, RPAR, IPAR, IDID)
      
C     Calculate analytical solution at final time
      OMEGA = DSQRT(MU / (ORBIT_RADIUS**3))
      ANGLE = OMEGA * XEND
      
C     Normalize angle to [0, 2π) to avoid trigonometric function errors with large angles
      ANGLE = DMOD(ANGLE, 2.0D0 * PI)
      IF (ANGLE .LT. 0.0D0) ANGLE = ANGLE + 2.0D0 * PI
      
      YANALYTICAL(1) = ORBIT_RADIUS * DCOS(ANGLE)
      YANALYTICAL(2) = ORBIT_RADIUS * DSIN(ANGLE)
      YANALYTICAL(3) = 0.0D0
      YANALYTICAL(4) = -OMEGA * ORBIT_RADIUS * DSIN(ANGLE)
      YANALYTICAL(5) = OMEGA * ORBIT_RADIUS * DCOS(ANGLE)
      YANALYTICAL(6) = 0.0D0
      
C     Calculate error (Euclidean norm of difference)
      ERROR = 0.0D0
      DO 30 I=1,N
         DIFF = Y(I) - YANALYTICAL(I)
         ERROR = ERROR + DIFF * DIFF
30    CONTINUE
      ERROR = DSQRT(ERROR)
      
C     Print results with appropriate format to avoid overflow
      WRITE(*,*) 'Two-Body Problem (Earth Orbit) - Numerical vs.',
     & ' Analytical Solution'
      WRITE(*,'(A,F12.1,A,F5.2,A)') ' Simulation time: ', XEND, 
     & ' s (', XEND / PERIOD, ' orbits)'
      WRITE(*,'(A,6(ES12.5,1X))') ' Numerical solution: ', 
     & (Y(I), I=1,6)
      WRITE(*,'(A,6(ES12.5,1X))') ' Analytical solution: ', 
     & (YANALYTICAL(I), I=1,6)
      WRITE(*,'(A,ES12.5)') ' Error: ', ERROR
      
      END
      
C     ------------------------------------------------
C     RIGHT-HAND SIDE OF TWO-BODY PROBLEM EQUATIONS
C     ------------------------------------------------
      SUBROUTINE FCN(N,X,Y,F,RPAR,IPAR)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION MU, R, R_CUBED
      DIMENSION Y(N),F(N),RPAR(*),IPAR(*)
      
C     Get gravitational parameter from RPAR
      MU = RPAR(1)
      
C     Calculate distance (r)
      R = DSQRT(Y(1)**2 + Y(2)**2 + Y(3)**2)
      R_CUBED = R**3
      
C     Position derivatives are just the velocities
      F(1) = Y(4)        ! dx/dt = vx
      F(2) = Y(5)        ! dy/dt = vy
      F(3) = Y(6)        ! dz/dt = vz
      
C     Velocity derivatives from Newton's law of gravitation
      F(4) = -MU * Y(1) / R_CUBED  ! dvx/dt = -mu * x / r^3
      F(5) = -MU * Y(2) / R_CUBED  ! dvy/dt = -mu * y / r^3
      F(6) = -MU * Y(3) / R_CUBED  ! dvz/dt = -mu * z / r^3
      
      RETURN
      END
      
C     ------------------------------------------------
C     DUMMY SOLOUT ROUTINE (NOT USED WITH IOUT=0)
C     ------------------------------------------------
      SUBROUTINE SOLOUT(NR, XOLD, X, Y, N, CON, ICOMP, ND,
     &                   RPAR, IPAR, IRTRN, XOUT)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION Y(N), CON(8*ND), ICOMP(ND), RPAR(*), IPAR(*)
      
C     DUMMY ROUTINE - NO OUTPUT DURING INTEGRATION
      IRTRN = 0
      
      RETURN
      END