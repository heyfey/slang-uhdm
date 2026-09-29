// § strLitContOwnerEnd224 (the conditional written as a macro argument)
`define SET(x, v) x = v;
module top(input logic c, output string o);
  always_comb begin
    `SET(o, c ? "x" : "ab \
cd")
  end
endmodule
