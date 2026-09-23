// face-2 unqualified measure: P = (OTHER > 1) ? {4'h1, 4'h2} : 8'h2
package pk;
  parameter logic [7:0] OTHER = 8'h5;
  parameter logic [7:0] P = (OTHER > 1) ? {4'h1, 4'h2} : 8'h2;
endpackage
module top import pk::*; (input logic [7:0] x, output logic [3:0] y);
  always_comb begin
    y = 4'd0;
    case (x)
      P: y = 4'd1;
      default: y = 4'd7;
    endcase
  end
endmodule
