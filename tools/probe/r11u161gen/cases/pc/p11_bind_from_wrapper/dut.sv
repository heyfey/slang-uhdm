// r11u161 port face (R5): a bind written in ANOTHER module (a wrapper) with named hierarchical connections (mriscv_bind_sva shape)
module dec(input logic [3:0] a, output logic [3:0] rs);
  assign rs = a;
endmodule
module core(input logic [3:0] a);
  dec d0 (.a(a), .rs());
endmodule
module chk(input logic [3:0] r0, input logic [3:0] r1);
endmodule
module top(input logic [3:0] a);
  core c0 (.a(a));
  core c1 (.a(~a));
endmodule
module Wrapper;
  bind top chk u_chk (.r0(c0.d0.rs), .r1(c1.d0.rs));
endmodule
