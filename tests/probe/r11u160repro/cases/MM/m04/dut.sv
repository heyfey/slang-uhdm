// § ppMacroBodyLines160
`define A(nm, p) \
  nm: assert property (@(posedge clk) (p)) \
    else begin \
      $error("fail"); \
    end
module top(input logic clk, input logic a, input logic b);
  `A(chk, a |->
      b)
endmodule
