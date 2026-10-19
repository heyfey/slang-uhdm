// § classImpTdParamTsClone408
package q;
  typedef logic [3:0] t;
endpackage
package p;
  import q::*;
  parameter t A = 4'd1;
endpackage
import p::*;
class c;
  int x;
endclass
module top;
  c h;
  initial h = new;
endmodule
