// r10v188repro/arms/v188_h_negsize.sv — THE NEGATIVE MODELLED SIZE.
// § enumConstLitArithRender188 ABSTAINS when `a.size - b` goes below zero
// (the `a188.size >= 0` guard), because that case was Surelog-reachable but
// unmeasured.  This arm measures it, so a later pass can take the cells instead
// of abstaining.  Every shape gets its OWN typedef because a shift past the
// left operand's width always evaluates to 0 and an enum's members must differ.
// MEASUREMENT ONLY — nothing here changes the shipped patch.
package v188h_pkg;
  typedef enum longint unsigned { H_M1  = 8'hFF >> 9  } v188h_m1_e;   // -1
  typedef enum longint unsigned { H_M2  = 8'hF0 >> 10 } v188h_m2_e;   // -2
  typedef enum longint unsigned { H_M4  = 8'hE0 >> 12 } v188h_m4_e;   // -4
  typedef enum longint unsigned { H_M8  = 4'h8 >> 12  } v188h_m8_e;   // -8
  typedef enum longint unsigned { H_S1  = 4'h8 >> 5   } v188h_s1_e;   // -1
  typedef enum longint unsigned { H_OK0 = 8'hFF >> 8  } v188h_ok0_e;  //  0
  typedef enum longint unsigned { H_OK1 = 8'hFE >> 7  } v188h_ok1_e;  //  1
endpackage
