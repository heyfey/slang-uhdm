// r11u161 port face (R5): ordered input connection to a 3-level hierarchical path
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
  chk u_chk (c0.d0.rs, c1.d0.rs);
endmodule
