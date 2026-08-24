// r10v80 v6 — a default that comes from a MACRO defined in an INCLUDED header,
// carried down an override chain.  MEASUREMENT ONLY.
`include "v6_defs.svh"
module v6_lf #(parameter int unsigned E = 4)(); wire [31:0] w = E; endmodule
module v6_h3 #(parameter int unsigned D = 3)(); v6_lf #(.E(D)) u(); endmodule
module v6_h2 #(parameter int unsigned C = 2)(); v6_h3 #(.D(C)) u(); endmodule
module v6_h1 #(parameter bit [3:0] B = `V6_W)(); v6_h2 #(.C(B)) u(); endmodule
module v6_h1b #(parameter logic [7:0] B = `V6_W8)(); v6_h2 #(.C(B)) u(); endmodule
module topv6();
  v6_h1  u_def0();                      // default IS the macro, NOT overridden
  v6_h1  #(.B(`V6_W))  u_ovm0();        // overridden WITH the same macro
  v6_h1  #(.B(4'h3))   u_ov0();
  v6_h1b u_def1();
  v6_h1b #(.B(`V6_W8)) u_ovm1();
  v6_h1b #(.B(8'h5a))  u_ov1();
endmodule
