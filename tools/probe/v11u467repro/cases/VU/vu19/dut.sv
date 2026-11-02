// § unitCopyOwnTsEveryPath467
package a;
  typedef struct packed { logic [3:0] x; logic y; } s_t;
  parameter s_t PS = '{x: 4'h2, y: 1'b1};
  parameter int PI = 4;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
import c::*;
module top;
  logic w;
endmodule
