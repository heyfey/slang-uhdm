// § tfFoldCaseInsideBoundModule282
package pk; parameter logic [1:0] P_LIT = 2'd1; endpackage
module c import pk::*; (input logic [1:0] a, output logic z);
  function automatic logic f(input logic [1:0] x);
    case (x) P_LIT: return 1'b1; default: return 1'b0; endcase
  endfunction
  assign z = f(a);
endmodule
module top(input logic [1:0] a, output logic [1:0] z);
  for (genvar i = 0; i < 2; i++) begin : g
    c u(.a(a), .z(z[i]));
  end
endmodule
