// § ppOutputLine166 (exploratory seed)
`define STR(__x) `"__x`"
`define ERR(__name)                               \
`ifdef UVM                                        \
  $display("A", `STR(__name), 1,                  \
           `__FILE__, `__LINE__);                 \
`else                                             \
  $error("%0t: %0s %0d", $time, `__LINE__,        \
         `STR(__name));                           \
`endif
module top(input clk, input a);
  always @(posedge clk) begin
    `ERR(chk)
  end
endmodule
