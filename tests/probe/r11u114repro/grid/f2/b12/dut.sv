// the same three, package-qualified, no import
package pk;
  localparam logic [7:0] P_ADD = 100 + 100;
  localparam logic [7:0] P_CADD = {4'h1, 4'h2} + 1;
  localparam logic [7:0] P_OR = 8'hF0 | 8'h0F;
  localparam logic [7:0] P_CAT = {4'h1, 4'h2};
endpackage
module top (input logic [7:0] x, output logic [3:0] y);
  always_comb begin
    y = 4'd0;
    case (x)
      pk::P_ADD:  y = 4'd1;
      pk::P_CADD: y = 4'd2;
      pk::P_OR:   y = 4'd3;
      pk::P_CAT:  y = 4'd4;
      default: y = 4'd7;
    endcase
  end
endmodule
