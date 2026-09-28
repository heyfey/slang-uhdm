// § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = 2;
endpackage
module top #(parameter logic [7:0] C = 8'h5a) (input logic [31:0] x, output logic [3:0] y1, output logic y2, output logic [31:0] y3);
  localparam logic [3:0] L = C[p::S:0];
  assign y1 = L;
  always_comb begin
    case (x[p::S:0])
      3'd1: y2 = 1'b1;
      default: y2 = 1'b0;
    endcase
  end
  assign y3 = $bits(x[p::S:0]);
endmodule
