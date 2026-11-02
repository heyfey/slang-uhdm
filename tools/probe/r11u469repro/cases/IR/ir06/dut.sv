// § importCopyTsInstByRole469
// a struct-typed parameter
package a;
  typedef struct packed { logic [3:0] f; } s_t;
  parameter s_t PS = '{f: 4'd2};
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
