// § pkgImpPackedArrElemCopy240: a struct element holding an enum and a nested struct member, a two-level re-export
package cp;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  typedef struct packed { logic [3:0] a; logic b; } in_t;
  typedef struct packed {
    e_t   k;
    in_t  n;
    logic [7:0] v;
  } ps_t;
  parameter ps_t [2:0] allc = '0;
endpackage
package bp;
  import cp::*;
  export cp::*;
  localparam int W = 4;
endpackage
package zp;
  import bp::*;
  localparam int Z = 2;
endpackage
module top
  import cp::*;
  import bp::*;
  import zp::*;
 (output logic [W-1:0] o);
  assign o = Z;
endmodule
