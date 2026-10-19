// § classImpTdParamTsClone408
package p;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  parameter s_t P = '{a: 4'd2, b: 1'b1};
endpackage
import p::*;
class c;
  int x;
endclass
module top;
  c h;
  initial h = new;
endmodule
