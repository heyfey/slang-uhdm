// § ppMacroBodyLines160
`define my_file `__FILE__
`define my_line `__LINE__
`define INFO(ID, MSG) \
  begin \
    if (1) \
      $display("%s %0d %s %s", `my_file, `my_line, ID, MSG); \
  end
module top(input logic clk);
  always @(posedge clk) `INFO("id", "msg")
endmodule
