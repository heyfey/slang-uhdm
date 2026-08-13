// r10earl43 — the OVER-FIRE / UNDER-FIRE probe for § defConnPkgParamFold43.
//
// Both kinds in the SAME module, same type, same value: an IMPORTED package
// localparam and a module-OWN localparam that is its exact twin.  If the gate
// is ever read as "this scope imports something" instead of "THIS PARAMETER
// lives in a package", E1_OWN folds too and the pass UNDER-fires invisibly.
//
// It also carries every non-integral package-parameter shape, because the fold
// takes the parameter's OWN def-view constant: a shape whose Rhs is not a
// constant must not fold at all.

package q43;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } st43_t;
  typedef enum logic [1:0] { E_A = 2'd0, E_B = 2'd1 } en43_t;
  localparam logic [31:0] Q_PLAIN  = 32'h 00008000;
  localparam st43_t       Q_STRUCT = '{a: 8'h aa, b: 8'h bb};
  localparam int          Q_ARR [0:1] = '{3, 4};
  localparam string       Q_STR    = "zz";
  localparam real         Q_REAL   = 1.5;
  localparam en43_t       Q_ENUM   = E_B;
endpackage

module sink43 #(parameter int W = 32) (input logic [31:0] p_i);
endmodule
module sinkst43 (input q43::st43_t p_i);
endmodule
module sinkar43 (input int p_i [0:1]);
endmodule
module sinkstr43 (input string p_i);
endmodule
module sinkre43 (input real p_i);
endmodule
module sinken43 (input q43::en43_t p_i);
endmodule

module mix43;
  import q43::*;
  // the module's OWN twin of Q_PLAIN: identical type, identical value
  localparam logic [31:0] E1_OWN = 32'h 00008000;
  // an own localparam whose VALUE comes from the package parameter
  localparam logic [31:0] E7_OWN_FROM_PKG = Q_PLAIN;

  sink43    u_e0 (.p_i (Q_PLAIN));           // imported pkg param  -> FOLDS
  sink43    u_e1 (.p_i (E1_OWN));            // module OWN param    -> ref_obj
  sinkst43  u_e2 (.p_i (Q_STRUCT));          // pkg packed-struct param
  sinkar43  u_e3 (.p_i (Q_ARR));             // pkg unpacked-array param
  sinkstr43 u_e4 (.p_i (Q_STR));             // pkg string param
  sinkre43  u_e5 (.p_i (Q_REAL));            // pkg real param
  sinken43  u_e6 (.p_i (Q_ENUM));            // pkg enum-typed param
  sink43    u_e7 (.p_i (E7_OWN_FROM_PKG));   // module OWN param    -> ref_obj
  sink43    u_e8 (.p_i (q43::Q_PLAIN));      // SCOPED written form
endmodule
