// face-2 unqualified measure: P = {4'h1, 4'h2} & 8'hF0
package pk;
  
  parameter logic [7:0] P = {4'h1, 4'h2} & 8'hF0;
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
