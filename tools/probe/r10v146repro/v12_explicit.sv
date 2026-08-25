// EXPLICIT import of ONE parameter; the sibling is reached only pkg-qualified.
package pv12;
  parameter int E_ONE = 21;
  parameter int E_TWO = 22;
endpackage
import pv12::E_ONE;
module top_v12;
  int a, b;
  initial begin
    a = E_ONE;
    b = pv12::E_TWO;
  end
endmodule
