// r10v66 arm 6 — PORT DIRECTIONS and CONNECTION FORMS: output/inout actuals,
// POSITIONAL connections, a gate primitive terminal, and a CLASS-scope enum
// constant read qualified inside an elaborated High_conn.
package vpk6;
  typedef enum logic [3:0] { RH = 4'h1, RB = 4'b0100, RD = 4'd6 } r4_t;
  class vc6;
    typedef enum logic [2:0] { CA = 3'h2, CB = 3'b101 } c3_t;
  endclass
endpackage

module vk6 (input logic i1, output logic o1, inout wire io1, input logic i2);
endmodule

module vtop6;
  import vpk6::*;
  logic [255:0] bus;
  wire  [255:0] wbus;
  wire          g_out;

  vk6 u_named (.i1(bus[RH]), .o1(bus[RB]), .io1(wbus[RD]), .i2(bus[vpk6::vc6::CA]));
  vk6 u_pos   (bus[RH], bus[RB], wbus[RD], bus[vpk6::vc6::CB]);

  not u_gate (g_out, bus[RH]);
  and u_gate2 (wbus[RB], bus[RH], bus[RD]);
endmodule
