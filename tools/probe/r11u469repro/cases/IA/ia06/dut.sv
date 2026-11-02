// § importCopyTsInstByRole469
// a struct typedef with a typedef'd member
package a;
  typedef logic [3:0] n_t;
  typedef struct packed { n_t x; logic y; } s_t;
  parameter s_t PS = '{x: 4'd3, y: 1'b1};
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
