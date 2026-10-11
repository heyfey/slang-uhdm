// § tfFoldCaseInsideBoundModule282
package pk; parameter int P = 4; endpackage
package q; import pk::*;
  class c; function int f(int x); case (x) P: return 1; default: return 0; endcase endfunction endclass
endpackage
module top(input logic [7:0] a, output logic [7:0] z); assign z = a; endmodule
