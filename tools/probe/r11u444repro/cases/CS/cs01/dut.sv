// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = "inv") (input clk, output reg o);
  localparam mn = 24;
  logic [mn+w:0] c;
  always_comb begin
    o = 1'b0;
    if (c[mn-1:lg] == 1'b1) o = 1'b1;
  end
endmodule
module m__abstract(); if (0) begin : abstract m not_used(); end endmodule
module top; endmodule
