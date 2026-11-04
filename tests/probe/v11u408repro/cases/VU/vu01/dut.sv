// § classImpTdParamTsClone408
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  parameter e_t P = B;
endpackage
import p::*;
class c;
  int x;
endclass
module top;
  c h;
  initial h = new;
endmodule
