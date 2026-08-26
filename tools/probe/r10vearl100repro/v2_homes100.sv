// v100 arm 2 — HOMES x DIRECTION x DRIVENNESS for a bare wildcard-imported
// net-like package struct port.  Every submodule below is a shape where the
// deleted route COULD fire in the pristine binary.
package vp2;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } al_t;
  typedef struct packed { al_t x; logic c; }              nest_t;   // nested struct member
  typedef logic [7:0]                                     byte_t;
  typedef struct packed { byte_t m; logic n; }            viatd_t;  // typedef-of-logic member
endpackage

// read-only input, no child instance, nothing driven  (route: undriven)
module v2_ro import vp2::*; (input al_t p, output logic [7:0] o);
  assign o = p.a;
endmodule

// output driven by a blocking always_comb  (route: procWrites)
module v2_blk import vp2::*; (input al_t p, output al_t q);
  always_comb q = p;
endmodule

// output driven by continuous assign
module v2_ca import vp2::*; (input al_t p, output al_t q);
  assign q = p;
endmodule

// output driven by always_ff nonblocking
module v2_ff import vp2::*; (input logic clk, input al_t p, output al_t q);
  always_ff @(posedge clk) q <= p;
endmodule

// inout
module v2_io import vp2::*; (inout al_t p, output logic [7:0] o);
  assign o = p.a;
endmodule

// input var keyword
module v2_var import vp2::*; (input var al_t p, output logic [7:0] o);
  assign o = p.b;
endmodule

// member-select assigned procedurally only
module v2_mem import vp2::*; (input al_t p, output al_t q);
  always_comb begin
    q.a = p.b;
    q.b = p.a;
  end
endmodule

// nested-struct member and typedef-of-logic member, undriven
module v2_nest import vp2::*; (input nest_t n, input viatd_t v, output logic o);
  assign o = n.c ^ v.n;
endmodule

// hands its port straight to a child; the child itself is undriven
module v2_pass import vp2::*; (input al_t p, output logic [7:0] o);
  v2_ro u_leaf (.p(p), .o(o));
endmodule

// parameterized, instantiated at two widths
module v2_par import vp2::*; #(parameter int W = 1) (input al_t p, output logic [W-1:0] o);
  assign o = {W{p.a[0]}};
endmodule

module v2_homes100 import vp2::*; ();

  al_t    s1, s2, s3, s4, s5, s7, s8, s9, sA, sB;
  wire al_t s6;
  nest_t  n1;
  viatd_t t1;
  logic   clk;
  logic [7:0] o1, o5, o6, o9;
  logic       oN;
  logic [0:0] oP1;
  logic [2:0] oP2;
  v2_ro   u_ro  (.p(s1), .o(o1));
  v2_blk  u_blk (.p(s2), .q(s3));
  v2_ca   u_ca  (.p(s3), .q(s4));
  v2_ff   u_ff  (.clk(clk), .p(s4), .q(s5));
  v2_io   u_io  (.p(s6), .o(o5));
  v2_var  u_var (.p(s7), .o(o6));
  v2_mem  u_mem (.p(s8), .q(s9));
  v2_nest u_nst (.n(n1), .v(t1), .o(oN));
  v2_pass u_pas (.p(sA), .o(o9));
  v2_par #(.W(1)) u_p1 (.p(sB), .o(oP1));
  v2_par #(.W(3)) u_p2 (.p(sB), .o(oP2));
  assign s1 = '0; assign s2 = '0; assign s6 = '0; assign s7 = '0;
  assign s8 = '0; assign sA = '0; assign sB = '0;
  assign n1 = '0; assign t1 = '0;
endmodule
