// face-2 qualified measure: pk::P = (OTHER > 1) ? {4'h1, 4'h2} : 8'h2
package pk;
  parameter logic [7:0] OTHER = 8'h5;
  parameter logic [7:0] P = (OTHER > 1) ? {4'h1, 4'h2} : 8'h2;
endpackage
module top (input logic [7:0] x, output logic [3:0] y);
  always_comb begin
    y = 4'd0;
    case (x)
      pk::P: y = 4'd1;
      default: y = 4'd7;
    endcase
  end
endmodule
