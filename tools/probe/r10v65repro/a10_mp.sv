// v65 ARM 10 — CONFIRM the modport carve-out: is the split MODPORT vs
// whole-interface, and does it hold at other depths / homes / positions?
// MEASUREMENT ONLY.
package pb;
  localparam int W = 16;
  localparam int B = 4;
endpackage
typedef struct packed { logic [63:0] addr; logic [63:0] data; } in_t;
typedef struct packed { in_t i; logic [63:0] p; } out_t;

interface ifb;
  logic [63:0] addr;
  in_t         r;
  out_t        o;
  modport mp  (input addr, input r, input o);
  modport mp2 (input addr, input r, input o);
endinterface

module lf (input logic [31:0] a_i, input logic b_i, output logic o_o);
  assign o_o = ^a_i ^ b_i;
endmodule

// modport port, depth 3, several homes and positions
module mpuse import pb::*; (ifb.mp p, output logic [7:0] o_o);
  lf i_w   (.a_i({16'b0, p.r.addr[0 +: W]}),  .b_i(p.addr[0]), .o_o(o_o[0]));
  lf i_b   (.a_i({16'b0, p.r.addr[B +: 16]}), .b_i(p.addr[0]), .o_o(o_o[1]));
  lf i_ps  (.a_i({16'b0, p.r.addr[W-1:B]}),   .b_i(p.addr[0]), .o_o(o_o[2]));
  lf i_bs  (.a_i(32'b0),                      .b_i(p.r.addr[B]), .o_o(o_o[3]));
  lf i_d4  (.a_i({16'b0, p.o.i.addr[0 +: W]}),.b_i(p.addr[0]), .o_o(o_o[4]));
  for (genvar g = 0; g < 2; g++) begin : gg
    lf i_g (.a_i({16'b0, p.r.addr[0 +: W]}), .b_i(p.addr[0]), .o_o(o_o[5+g]));
  end
  // cont_assign control (never inside a High_conn)
  logic [15:0] ca; assign ca = p.r.addr[0 +: W];
  assign o_o[7] = ^ca;
endmodule

// the SECOND modport name, and a whole-interface port for contrast
module mp2use import pb::*; (ifb.mp2 p, output logic o_o);
  lf i_w2 (.a_i({16'b0, p.r.addr[0 +: W]}), .b_i(p.addr[0]), .o_o(o_o));
endmodule
module wholeuse import pb::*; (ifb p, output logic [1:0] o_o);
  lf i_wh (.a_i({16'b0, p.r.addr[0 +: W]}),   .b_i(p.addr[0]), .o_o(o_o[0]));
  lf i_w4 (.a_i({16'b0, p.o.i.addr[0 +: W]}), .b_i(p.addr[0]), .o_o(o_o[1]));
endmodule
// GENERIC interface port
module genuse import pb::*; (interface p, output logic o_o);
  lf i_gn (.a_i({16'b0, p.r.addr[0 +: W]}), .b_i(p.addr[0]), .o_o(o_o));
endmodule

module a10_mp import pb::*; (input out_t d_i, output logic [15:0] o_o);
  ifb the_if ();
  assign the_if.addr = d_i.p;
  assign the_if.r    = d_i.i;
  assign the_if.o    = d_i;
  mpuse    u_mp  (.p(the_if.mp),  .o_o(o_o[7:0]));
  mp2use   u_mp2 (.p(the_if.mp2), .o_o(o_o[8]));
  wholeuse u_wh  (.p(the_if),     .o_o(o_o[10:9]));
  genuse   u_gn  (.p(the_if.mp),  .o_o(o_o[11]));
  assign o_o[15:12] = 4'b0;
endmodule
