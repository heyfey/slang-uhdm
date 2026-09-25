// § ppOutputCol166
`define ST_A 2'd0
`define ST_B 2'd1
module top(input logic [1:0] s, output logic y);
  always_comb begin
    case (s)
      `ST_A: y = 1'b0;
      `ST_B: y = 1'b1;
      default: y = 1'b0;
    endcase
  end
endmodule
