// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = "inv") (input clk, output reg o);
  logic [23:0] c;
  always_comb begin
    o = 1'b0;
    case (lg)
      "inv": o = 1'b1;
      default: o = c[23:lg];
    endcase
  end
endmodule
module top; endmodule
