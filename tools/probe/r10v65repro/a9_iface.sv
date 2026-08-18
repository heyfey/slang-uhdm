// v65 ARM 9 — ISOLATE the a7 AWAY-GOLDEN cell: is the distinguisher the
// HIER-PATH DEPTH or an INTERFACE-rooted actual?  MEASUREMENT ONLY.
package pa9;
  localparam int W = 16;
endpackage

typedef struct packed { logic [63:0] addr; logic [63:0] data; } inner9_t;
typedef struct packed { inner9_t in; logic [63:0] pad; } outer9_t;

interface if9;
  logic [63:0] addr;
  inner9_t     r;
  modport mp (input addr, input r);
endinterface

module leaf9 (input logic [31:0] a_i, input logic b_i, output logic o_o);
  assign o_o = ^a_i ^ b_i;
endmodule

// (a) DEPTH 3 through a plain STRUCT-OF-STRUCT port — no interface anywhere
module d3_9 import pa9::*; (input outer9_t o_i, output logic o_o);
  leaf9 i_d3 (.a_i({16'b0, o_i.in.addr[0 +: W]}), .b_i(o_i.pad[0]), .o_o(o_o));
endmodule

// (b) DEPTH 2 through an interface MODPORT port
module ifm2_9 import pa9::*; (if9.mp p, output logic o_o);
  leaf9 i_m2 (.a_i({16'b0, p.addr[0 +: W]}), .b_i(p.addr[0]), .o_o(o_o));
endmodule

// (c) DEPTH 3 through an interface MODPORT port
module ifm3_9 import pa9::*; (if9.mp p, output logic o_o);
  leaf9 i_m3 (.a_i({16'b0, p.r.addr[0 +: W]}), .b_i(p.addr[0]), .o_o(o_o));
endmodule

// (d) DEPTH 2/3 through a WHOLE-INTERFACE port (no modport)
module ifw_9 import pa9::*; (if9 p, output logic [1:0] o_o);
  leaf9 i_w2 (.a_i({16'b0, p.addr[0   +: W]}), .b_i(p.addr[0]), .o_o(o_o[0]));
  leaf9 i_w3 (.a_i({16'b0, p.r.addr[0 +: W]}), .b_i(p.addr[0]), .o_o(o_o[1]));
endmodule

module a9_iface import pa9::*; (input outer9_t o_i, output logic [7:0] o_o);
  if9 the_if ();
  assign the_if.addr = o_i.pad;
  assign the_if.r    = o_i.in;
  d3_9   u_d3 (.o_i(o_i),          .o_o(o_o[0]));
  ifm2_9 u_m2 (.p(the_if.mp),      .o_o(o_o[1]));
  ifm3_9 u_m3 (.p(the_if.mp),      .o_o(o_o[2]));
  ifw_9  u_w  (.p(the_if),         .o_o(o_o[4:3]));
  // (e) the interface INSTANCE named from the parent, directly in a port conn
  leaf9  u_pi2 (.a_i({16'b0, the_if.addr[0   +: W]}), .b_i(the_if.addr[0]), .o_o(o_o[5]));
  leaf9  u_pi3 (.a_i({16'b0, the_if.r.addr[0 +: W]}), .b_i(the_if.addr[0]), .o_o(o_o[6]));
  // (f) DEPTH 3 plain struct at THIS level (control for u_d3)
  leaf9  u_ps3 (.a_i({16'b0, o_i.in.addr[0 +: W]}), .b_i(o_i.pad[0]), .o_o(o_o[7]));
endmodule
