// § modAggTfArgCloneFollows180 § modAggCloneTakesFile180v (r11u190: a module typedef in the main file, its formal writer in an INCLUDED function file; a localparam copy)
module top(output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
`include "fn.svh"
  localparam op_t P = '{a:4'h9, b:4'h3};
  assign o = f(P);
endmodule
