// § aliasTdMembTsInstAtAlias484 (package alias of a struct with an enum and a nested struct member, imported by top)
package u;
  typedef enum logic [1:0] { A, B } e_t;
  typedef struct packed { logic [3:0] x; } in_t;
  typedef struct packed { in_t i; e_t e; } op_t;
  typedef op_t op2_t;
endpackage
module top(input logic [5:0] i, output logic [3:0] o);
  import u::*;
  op2_t w;
  assign w = i;
  assign o = w.i.x;
endmodule
