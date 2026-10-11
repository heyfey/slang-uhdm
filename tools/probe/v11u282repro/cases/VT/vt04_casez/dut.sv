// § tfFoldCaseInsideBoundModule282
package pk; parameter logic [1:0] P_LIT = 2'd1; endpackage
module top import pk::*; (input logic [1:0] a, output logic z);
  function automatic logic f(input logic [1:0] x);
    unique casez (x) P_LIT, 2'd3: f = 1'b1; default: f = 1'b0; endcase
  endfunction
  assign z = f(a);
endmodule
