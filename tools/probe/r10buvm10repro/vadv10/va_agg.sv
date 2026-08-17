// verifier arm A' -- CHAIN DEPTH.  (Aggregate bases are REJECTED BY SLANG:
// "invalid enum base type (must be a single dimensional integer type)" for a
// packed struct, a packed union and an enum, so the new chained0 branch can
// never see one -- recorded as SLANG-FENCED, not guessed.)
package pa10;
  typedef bit [3:0] t_b0;
  typedef t_b0      t_b1;
  typedef t_b1      t_b2;
  typedef t_b2      t_b3;
  typedef enum t_b0 { G0 = 0, G1 = 1 } e_b0;
  typedef enum t_b1 { H0 = 0, H1 = 1 } e_b1;
  typedef enum t_b2 { I0 = 0, I1 = 1 } e_b2;
  typedef enum t_b3 { J0 = 0, J1 = 1 } e_b3;
endpackage
module vaTop10;
  pa10::e_b0 v0;
  pa10::e_b1 v1;
  pa10::e_b2 v2;
  pa10::e_b3 v3;
endmodule
