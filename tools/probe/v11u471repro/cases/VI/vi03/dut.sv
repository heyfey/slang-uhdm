// § pkgInitImpReadFolds471
// typedef range and struct pattern reading an imported parameter
package a;
  parameter int W = 6;
endpackage
package b;
  import a::*;
  typedef logic [W-1:0] w_t;
  typedef struct packed { logic [3:0] f; logic [3:0] g; } s_t;
  localparam s_t LS = '{f: W, g: 4'd1};
  localparam w_t LW = W;
endpackage
module top(output logic [5:0] y);
  import b::*;
  assign y = LW;
endmodule
