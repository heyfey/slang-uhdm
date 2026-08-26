// r10earl100 ARM g2 — USES x HOMES for a NET-LIKE package struct.  MEASUREMENT ONLY.
package gp2;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } nl_t;
  typedef enum logic [1:0] { B0, B1 } be_t;
  typedef struct packed { logic [3:0] a; be_t e; }        vr_t;
endpackage

// read only
module u_ro import gp2::*; (input nl_t p, input vr_t q, output logic o);
  assign o = ^{p, q};
endmodule
// continuous assign drives the output struct port
module u_ca import gp2::*; (input nl_t p, output nl_t r, output vr_t s);
  assign r = p; assign s = '0;
endmodule
// always_comb (blocking) writes a MEMBER of the output struct port
module u_cb import gp2::*; (input nl_t p, output nl_t r, output vr_t s);
  always_comb begin r.a = p.a; r.b = p.b; s = '0; end
endmodule
// always_ff (nonblocking)
module u_ff import gp2::*; (input logic c, input nl_t p, output nl_t r, output vr_t s);
  always_ff @(posedge c) begin r <= p; s <= '0; end
endmodule
// both a cont assign and a procedural write on DIFFERENT struct ports
module u_both import gp2::*; (input nl_t p, output nl_t r, output vr_t s);
  assign r = p;
  always_comb s.a = p.a;
  always_comb s.e = B0;
endmodule
// never wired at all
module u_none import gp2::*; (input nl_t p, output nl_t r, output vr_t s, input logic i, output logic o);
  assign o = i;
endmodule
// port-connected: hands its struct port straight to a child
module u_pass import gp2::*; (input nl_t p, input vr_t q, output logic o);
  u_ro u_leaf (.p(p), .q(q), .o(o));
endmodule
// a PARAMETERIZED submodule
module u_par import gp2::*; #(int unsigned W = 4) (input nl_t p, output logic [W-1:0] o);
  assign o = {W{^p}};
endmodule
// an INTERFACE home
interface if2 import gp2::*; (input logic c);
  nl_t  i_net;
  vr_t  i_var;
  logic i_l;
  assign i_l = c;
  modport mp (input i_net, input i_var, output i_l);
endinterface

module g2_top import gp2::*; (input logic c, output logic o);
  nl_t t_p; vr_t t_q; nl_t t_r1, t_r2, t_r3, t_r4, t_r5;
  vr_t t_s1, t_s2, t_s3, t_s4, t_s5;
  logic o1,o2,o3,o4,o5;
  logic [3:0] ow1;
  logic [7:0] ow2;
  if2 u_if (.c(c));
  u_ro   u1 (.p(t_p), .q(t_q), .o(o1));
  u_ca   u2 (.p(t_p), .r(t_r1), .s(t_s1));
  u_cb   u3 (.p(t_p), .r(t_r2), .s(t_s2));
  u_ff   u4 (.c(c), .p(t_p), .r(t_r3), .s(t_s3));
  u_both u5 (.p(t_p), .r(t_r4), .s(t_s4));
  u_none u6 (.p(t_p), .r(t_r5), .s(t_s5), .i(c), .o(o2));
  u_pass u7 (.p(t_p), .q(t_q), .o(o3));
  u_par #(.W(4)) u8 (.p(t_p), .o(ow1));
  u_par #(.W(8)) u9 (.p(t_p), .o(ow2));
  // a GEN SCOPE home
  generate
    if (1) begin : gblk
      nl_t g_net;
      vr_t g_var;
      assign g_net = t_p;
      u_ro u_g (.p(g_net), .q(g_var), .o(o4));
    end
  endgenerate
  assign o5 = ^{ow1, ow2, t_r1, t_r2, t_r3, t_r4, t_r5, t_s1, t_s2, t_s3, t_s4, t_s5};
  assign o = o1 ^ o2 ^ o3 ^ o4 ^ o5;
endmodule
