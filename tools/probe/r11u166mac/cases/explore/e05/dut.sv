// § ppOutputLine166 (exploratory seed)
`define STR(__x) `"__x`"
`define DCLK clk
`define ERR(__name)                               \
`ifdef UVM                                        \
  $display("A", `STR(__name), 1,                  \
           `__FILE__, `__LINE__);                 \
`else                                             \
  $error("%0t: %0s %0d", $time, `__LINE__,        \
         `STR(__name));                           \
`endif
`define CHK(__name, __prop, __clk = `DCLK)                             \
  __name: assert property (@(posedge __clk) (__prop))                  \
    else begin                                                         \
      `ERR(__name)                                                     \
    end
module top(input clk, input a, input b);
  `CHK(ChkA, a |->
      b)
  `CHK(ChkB, a)
endmodule
