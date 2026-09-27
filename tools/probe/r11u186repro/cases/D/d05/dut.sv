// § boundLitUnderscoreDropped186 (range bounds, a case item, a wide value)
module top(input logic [1_5:0] a, output logic [3_1:0] o);
  logic [7:0] m [0:1_5];
  always_comb begin
    case (a)
      1_0: o = 64'd1_000_000_000_000;
      default: o = 3_2'd7;
    endcase
  end
endmodule
