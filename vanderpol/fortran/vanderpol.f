C     PROGRAM TO SOLVE VAN DER POL USING ORIGINAL HAIRER DOP853
      PROGRAM VDPHAIRER
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (N=2)
      DIMENSION Y(N),RTOL(1),ATOL(1),WORK(3000),IWORK(1000)
      DIMENSION RPAR(1),IPAR(1)
      EXTERNAL FCN, SOLOUT
      
      ! Declare timing variables for system_clock
      INTEGER(8) COUNT_START, COUNT_END, COUNT_RATE, COUNT_MAX
      DOUBLE PRECISION ELAPSED_TIME
      
C     Set parameters to match Rust version
      RPAR(1) = 0.2D0      ! mu = 0.2
      X = 0.0D0            ! t0 = 0.0
      XEND = 1000.0D0      ! tf = 1000.0
      Y(1) = 0.0D0         ! x = 0.0
      Y(2) = 0.1D0         ! y = 0.1
      ATOL(1) = 1.0D-12    ! atol = 1e-12
      RTOL(1) = 1.0D-12    ! rtol = 1e-12
      
C     SET METHOD PARAMETERS
      ITOL = 0
      IOUT = 0
      IDID = 0
      
C     INITIALIZE WORK ARRAYS
      DO 10 I=1,3000
         WORK(I) = 0.0D0
10    CONTINUE
      DO 20 I=1,1000
         IWORK(I) = 0
20    CONTINUE
      
C     START TIMING USING SYSTEM_CLOCK
      CALL SYSTEM_CLOCK(COUNT_START, COUNT_RATE, COUNT_MAX)
      
C     CALL THE INTEGRATOR
      CALL DOP853(N,FCN,X,Y,XEND,
     &            RTOL,ATOL,ITOL,
     &            SOLOUT,IOUT,
     &            WORK,3000,IWORK,1000,RPAR,IPAR,IDID)
     
C     END TIMING
      CALL SYSTEM_CLOCK(COUNT_END)
      ELAPSED_TIME = DBLE(COUNT_END - COUNT_START) / DBLE(COUNT_RATE)
      
C     PRINT RESULT IN CONSISTENT FORMAT
      WRITE(*,'(A,F7.1,A,F8.5,A,F8.5)') 't =', XEND, ', u = ',
     &                                   Y(1), ',', Y(2)
      
      END
      
C     ------------------------------------------------
C     RIGHT-HAND SIDE OF VAN DER POL EQUATION
C     ------------------------------------------------
      SUBROUTINE FCN(N,X,Y,F,RPAR,IPAR)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION Y(N),F(N),RPAR(*),IPAR(*)
      
C     VAN DER POL WITH MU FROM RPAR(1)
      DOUBLE PRECISION MU
      MU = RPAR(1)
      
      F(1) = Y(2)
      F(2) = MU*(1.0D0-Y(1)**2)*Y(2) - Y(1)
      
      RETURN
      END
      
C     ------------------------------------------------
C     DUMMY SOLOUT ROUTINE (NOT USED WITH IOUT=0)
C     ------------------------------------------------
      SUBROUTINE SOLOUT(NR,XOLD,X,Y,N,CON,ICOMP,ND,
     &                   RPAR,IPAR,IRTRN,XOUT)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION Y(N),CON(8*ND),ICOMP(ND),RPAR(*),IPAR(*)
      
C     DUMMY ROUTINE - NO OUTPUT DURING INTEGRATION
      IRTRN = 0
      
      RETURN
      END
