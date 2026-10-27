// § defaultedStrPlaceholderRetry444
module m #(parameter w, lg = "inv") (input clk, output reg o);
  localparam mn = 24;
  logic [mn+w:0] c;
  function automatic logic f(input logic [mn+w:0] x);
    return x[mn-1:lg] == 1'b1;
  endfunction
  always_comb o = f(c);
endmodule
module top; endmodule
