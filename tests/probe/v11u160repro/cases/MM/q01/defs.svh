`define ASRT(name, cond) \
`ifdef NOPE \
  initial $display("x"); \
`endif \
  assign name = cond;
