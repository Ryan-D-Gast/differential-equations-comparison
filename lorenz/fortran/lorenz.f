C     PROGRAM TO SOLVE LORENZ SYSTEM USING HAIRER DOP853
      PROGRAM LORENZHAIRER
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (N=3)
      DIMENSION Y(N), RTOL(1), ATOL(1), WORK(5000), IWORK(1000)
      DIMENSION RPAR(3), IPAR(1)
      EXTERNAL FCN, SOLOUT
      
C     Set parameters to match Rust version
C     Lorenz parameters in RPAR
      RPAR(1) = 10.0D0         ! sigma = 10.0
      RPAR(2) = 28.0D0         ! rho = 28.0
      RPAR(3) = 8.0D0/3.0D0    ! beta = 8.0/3.0
      
      X = 0.0D0                ! t0 = 0.0
      XEND = 10000.0D0         ! tf = 10000.0 (long simulation for benchmarking)
      
C     Initial conditions
      Y(1) = 1.0D0             ! x = 1.0
      Y(2) = 1.0D0             ! y = 1.0
      Y(3) = 1.0D0             ! z = 1.0
      
C     Set tolerances to match Rust version
      ATOL(1) = 1.0D-12        ! atol = 1e-12
      RTOL(1) = 1.0D-12        ! rtol = 1e-12
      
C     Set method parameters
      ITOL = 0
      IOUT = 0
      IDID = 0
      
C     Initialize work arrays
      DO 10 I=1,5000
         WORK(I) = 0.0D0
10    CONTINUE
      DO 20 I=1,1000
         IWORK(I) = 0
20    CONTINUE

C     Set maximum number of steps
      IWORK(1) = 1000000        ! max number of steps
      
C     Call the integrator
      CALL DOP853(N, FCN, X, Y, XEND,
     &            RTOL, ATOL, ITOL,
     &            SOLOUT, IOUT,
     &            WORK, 5000, IWORK, 1000, RPAR, IPAR, IDID)
      
C     Print result in same format as Rust version
      WRITE(*,'(A,F8.1,A,F8.5,A,F8.5,A,F8.5)') 't =', XEND, ', u = ',
     &                                  Y(1), ', ', Y(2), ', ', Y(3)
      
      END
      
C     ------------------------------------------------
C     RIGHT-HAND SIDE OF LORENZ SYSTEM
C     ------------------------------------------------
      SUBROUTINE FCN(N,X,Y,F,RPAR,IPAR)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION Y(N),F(N),RPAR(*),IPAR(*)
      
C     LORENZ PARAMETERS FROM RPAR
      SIGMA = RPAR(1)
      RHO = RPAR(2)
      BETA = RPAR(3)
      
C     LORENZ SYSTEM EQUATIONS
      F(1) = SIGMA * (Y(2) - Y(1))
      F(2) = Y(1) * (RHO - Y(3)) - Y(2)
      F(3) = Y(1) * Y(2) - BETA * Y(3)
      
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
