C     PROGRAM TO SOLVE CR3BP USING HAIRER DOP853
      PROGRAM CR3BPHAIRER
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (N=6)
      DIMENSION Y(N), RTOL(1), ATOL(1), WORK(8000), IWORK(1000)
      DIMENSION RPAR(1), IPAR(1)
      EXTERNAL FCN, SOLOUT
      
C     Set parameters to match Rust version
      RPAR(1) = 0.012150585609624D0 ! Earth-Moon mass ratio
      X = 0.0D0                      ! t0 = 0.0
      XEND = 10.0D0 * 1.509263667286943D0 ! tf = 3 * (orbital period)
      
C     Initial state vector (x, y, z, vx, vy, vz)
      Y(1) = 1.021881345465263D0 ! x
      Y(2) = 0.0D0               ! y
      Y(3) = -0.182000000000000D0 ! z
      Y(4) = 0.0D0               ! vx
      Y(5) = -0.102950816739606D0 ! vy
      Y(6) = 0.0D0               ! vz
      
C     Set tolerances to match Rust version
      ATOL(1) = 1.0D-12          ! atol = 1e-12
      RTOL(1) = 1.0D-12          ! rtol = 1e-12
      
C     Set method parameters
      ITOL = 0
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
      
C     Print result in same format as Rust version
      WRITE(*,'(A,F7.1,A,F8.5,A,F8.5,A,F8.5)') 't =', XEND, ', u = ',
     &                                   Y(1), ', ', Y(2), ', ', Y(3)
      
      END
      
C     ------------------------------------------------
C     RIGHT-HAND SIDE OF CR3BP EQUATION
C     ------------------------------------------------
      SUBROUTINE FCN(N,X,Y,F,RPAR,IPAR)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION Y(N),F(N),RPAR(*),IPAR(*)
      
C     CR3BP WITH MU FROM RPAR(1)
      DOUBLE PRECISION MU
      MU = RPAR(1)
      
C     COMPUTE DISTANCES TO PRIMARY MASSES - EXACTLY AS IN RUST VERSION
      R13 = DSQRT((Y(1) + MU)**2 + Y(2)**2 + Y(3)**2)
      R23 = DSQRT((Y(1) - 1.0D0 + MU)**2 + Y(2)**2 + Y(3)**2)
      
C     EQUATIONS OF MOTION IN THE ROTATING FRAME - MATCH RUST VERSION EXACTLY
      F(1) = Y(4)
      F(2) = Y(5)
      F(3) = Y(6)
      F(4) = Y(1) + 2.0D0 * Y(5) 
     &       - (1.0D0 - MU) * (Y(1) + MU) / R13**3
     &       - MU * (Y(1) - 1.0D0 + MU) / R23**3
      F(5) = Y(2) - 2.0D0 * Y(4) 
     &       - (1.0D0 - MU) * Y(2) / R13**3 
     &       - MU * Y(2) / R23**3
      F(6) = -(1.0D0 - MU) * Y(3) / R13**3 
     &       - MU * Y(3) / R23**3
      
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
