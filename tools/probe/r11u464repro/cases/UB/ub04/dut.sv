// § unitClsListsSpecBase464 (a value-parameter specialization typedef)
package a;
  class S #(int N = 1);
    logic [N-1:0] r;
  endclass
  typedef S #(4) S4;
endpackage
import a::*;
class test;
  S4 q;
endclass
module top;
  initial begin test t; t = new; end
endmodule
