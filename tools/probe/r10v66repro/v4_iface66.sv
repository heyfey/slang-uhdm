// r10v66 arm 4 — INTERFACES: an interface instance's own port connections, an
// interface-port child, and a MODPORT-ROOTED hierarchical actual (earl65's
// carve-out lives here).
package vpk4;
  typedef enum logic [3:0] { FH = 4'h2, FB = 4'b0111 } f4_t;
endpackage

interface vif4 #(parameter int W = 16) (input logic clk);
  import vpk4::*;
  logic [W-1:0] sig;
  logic         bit0;
  modport mp (input sig, output bit0);
  modport mpx (input sig, input bit0);
endinterface

module vk4 (input logic z1, input logic z2);
endmodule

module vk4i (vif4.mp p, input logic z3);
  logic w1;
  assign w1 = p.sig[vpk4::FH];
  vk4 u_deep (.z1(p.sig[vpk4::FH]), .z2(p.sig[vpk4::FB]));
endmodule

module vtop4 (input logic clk);
  import vpk4::*;
  logic [255:0] bus;
  vif4 #(.W(16)) u_if (.clk(clk));
  vk4  u_p (.z1(bus[FH]), .z2(bus[FB]));
  vk4i u_c (.p(u_if.mp), .z3(u_if.sig[FH]));
  vk4  u_q (.z1(u_if.sig[FH]), .z2(u_if.sig[FB]));
endmodule
