// § ppMacroBodyLines160
`define REPORT(v) \
  initial begin \
    $display("%s:%0d v=%0d", `__FILE__, `__LINE__, v); \
    $display("again %0d", `__LINE__); \
  end
module top (input logic [3:0] a);
  wire unused_w; `REPORT(a)
endmodule
