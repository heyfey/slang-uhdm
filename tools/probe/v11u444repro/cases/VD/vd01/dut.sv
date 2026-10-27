// § defaultedStrPlaceholderRetry444
module ca(input clk); logic qa; endmodule
module cb(input clk); logic qb; endmodule
module m #(parameter w, lg = "abc") (input clk, output reg o);
  logic [23:0] c;
  if (lg == "abc") begin : g1
    ca ua(.clk(clk));
  end else begin : g2
    cb ub(.clk(clk));
  end
  always_comb begin
    o = 1'b0;
    if (c[23:lg] == 1'b1) o = 1'b1;
  end
endmodule
module top; endmodule
