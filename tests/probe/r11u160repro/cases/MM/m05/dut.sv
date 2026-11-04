// § ppMacroBodyLines160
`define E(n) \
  $error("fail %0s", \
         n);
`define A(nm, p) \
  nm: assert property (@(posedge clk) (p)) \
    else begin \
      `E("x") \
    end
module top(input logic clk, input logic a, input logic b);
  `A(chk, a |-> b)
endmodule
