// § classImpTdParamTsClone408
package p;
  parameter bit [3:0] A = 4'd5;
endpackage
import p::*;
class c;
  int x;
endclass
module top;
  c h;
  initial h = new;
endmodule
