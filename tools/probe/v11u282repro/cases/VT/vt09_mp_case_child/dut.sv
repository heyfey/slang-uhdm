// § tfFoldCaseInsideBoundModule282
module c #(parameter logic [1:0] P_LIT = 2'd1) (input logic [1:0] a, output logic z);
  function automatic logic f(input logic [1:0] x);
    case (x) P_LIT: return 1'b1; default: return 1'b0; endcase
  endfunction
  assign z = f(a);
endmodule
module top(input logic [1:0] a, output logic z1, output logic z2); c u1(.a(a), .z(z1)); c #(.P_LIT(2'd2)) u2(.a(a), .z(z2)); endmodule
