// § tfFoldCaseInsideBoundModule282
package pk; parameter logic [1:0] P_LIT = 2'd1; endpackage
module top import pk::*; (input logic [1:0] a, output logic z);
  if (1) begin : g
    function automatic logic f(input logic [1:0] x);
      case (x) P_LIT: return 1'b1; default: return 1'b0; endcase
    endfunction
    assign z = f(a);
  end
endmodule
