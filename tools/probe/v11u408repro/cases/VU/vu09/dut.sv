// § classImpTdParamTsClone408
package p;
  typedef int arr_t [2];
  parameter arr_t A = '{1, 2};
endpackage
import p::*;
class c;
  int x;
endclass
module top;
  c h;
  initial h = new;
endmodule
