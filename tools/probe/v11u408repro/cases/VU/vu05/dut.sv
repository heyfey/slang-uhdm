// § classImpTdParamTsClone408
package p;
  typedef int i_t;
  parameter i_t A = 3;
  localparam i_t B = 4;
endpackage
import p::*;
class c;
  int x;
endclass
module top;
  c h;
  initial h = new;
endmodule
