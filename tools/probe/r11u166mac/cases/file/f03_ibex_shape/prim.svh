`define DCLK clk_i
`define DRST !rst_ni
`define STRG(__x) `"__x`"
`define ERRX(__name)                                           \
`ifdef UVM                                                     \
  $display("A", `STRG(__name), 1,                              \
           `__FILE__, `__LINE__);                              \
`else                                                          \
  $error("%0t: (%0s:%0d) %0s", $time, `__FILE__, `__LINE__,     \
         `STRG(__name));                                       \
`endif
`define CHKK(__name, __prop, __clk = `DCLK, __rst = `DRST)      \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))   \
    else begin                                                 \
      `ERRX(__name)                                            \
    end
