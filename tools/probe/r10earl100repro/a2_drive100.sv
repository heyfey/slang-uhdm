// r10earl100 ARM a2 — DRIVENNESS x DIRECTION x var/wire keyword.  MEASUREMENT ONLY.
package q100;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } al_t;
endpackage

// read-only struct port, no child instance  (the sha2_pad shape)
module m_ro import q100::*; (input al_t p, output logic o);
  logic z; assign z = ^p.a; assign o = z;
endmodule

// struct port written procedurally (blocking) -- rsp_gen shape but net-like
module m_procw import q100::*; (input al_t pi, output al_t po, output logic o);
  always_comb begin po.a = pi.a; po.b = pi.b; end
  assign o = ^pi;
endmodule

// struct port written by a continuous assign
module m_ca import q100::*; (input al_t pi, output al_t po);
  assign po = pi;
endmodule

// struct port written non-blocking in always_ff
module m_ff import q100::*; (input logic c, input al_t pi, output al_t po);
  always_ff @(posedge c) po <= pi;
endmodule

// struct port handed to a child instance
module m_child import q100::*; (input al_t pi, output logic o);
  m_ro u_ro (.p(pi), .o(o));
endmodule

// var keyword on the port
module m_var import q100::*; (input var al_t pv, output logic o);
  assign o = ^pv;
endmodule

// inout struct port, read only
module m_io import q100::*; (inout al_t pio, output logic o);
  assign o = ^pio;
endmodule

// output struct port never driven
module m_outu import q100::*; (output al_t pou, input logic i);
  logic k; assign k = i;
endmodule

// body declarations: plain / wire / var / with an initializer
module m_body import q100::*; (input logic i, output logic o);
  al_t d_plain;
  var al_t d_var;
  al_t d_init = '{a:4'h1, b:4'h2};
  assign d_plain = {i,i,i,i,i,i,i,i};
  assign o = ^{d_plain, d_var, d_init};
endmodule

// unpacked array of the struct, and a packed array of it
module m_arr import q100::*; (input logic i, output logic o);
  al_t ua [2];
  al_t [1:0] pa;
  assign o = ^{ua[0], ua[1], pa, i};
endmodule

module top2 import q100::*; (input al_t t, input logic c, output logic o);
  al_t w; assign w = t;
  logic o1,o2,o3,o4,o5,o6;
  al_t y1,y2,y3;
  wire al_t y4;
  m_ro    u1 (.p(w), .o(o1));
  m_procw u2 (.pi(w), .po(y1), .o(o2));
  m_ca    u3 (.pi(w), .po(y2));
  m_ff    u4 (.c(c), .pi(w), .po(y3));
  m_child u5 (.pi(w), .o(o3));
  m_var   u6 (.pv(w), .o(o4));
  m_io    u7 (.pio(y4), .o(o5));
  m_outu  u8 (.pou(), .i(c));
  m_body  u9 (.i(c), .o(o6));
  m_arr   u10(.i(c), .o(o));
endmodule
