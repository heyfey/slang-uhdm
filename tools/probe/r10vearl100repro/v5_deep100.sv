// v100 arm 5 — homes the first round did not reach: a struct-ported module
// instantiated INSIDE a generate scope, inside an interface, a port with a
// DEFAULT VALUE (the deleted route's `!getInitializer()` guard), an unpacked
// array-of-struct port, and the same module instantiated under two gen arms.
package vp5;
  typedef struct packed { logic [7:0] a; logic [7:0] b; }  al_t;
  typedef struct packed { al_t x; logic c; }               nest_t;
  typedef enum logic { W0, W1 } w_t;
  typedef struct packed { logic [3:0] d; w_t e; }          vr_t;
endpackage

// route fires: no struct port wired
module v5_leaf import vp5::*; (input al_t p, output logic [7:0] o);
  assign o = p.a;
endmodule

// a struct port with a DEFAULT VALUE, plus a blocking write to another
module v5_dflt import vp5::*; (input al_t p = '0, output al_t q, output logic [7:0] o);
  always_comb q = p;
  assign o = p.b;
endmodule

// unpacked ARRAY of package struct as a port, nothing wired
module v5_arr import vp5::*; (input al_t ap [0:1], input nest_t np, input vr_t vp_,
                              output logic [7:0] o);
  assign o = ap[0].a ^ ap[1].b ^ np.c ^ vp_.d;
endmodule

interface v5_if import vp5::*; (input logic clk);
  al_t   if_net;
  vr_t   if_var;
  logic [7:0] o_in_if;
  assign o_in_if = if_net.a;
endinterface

module v5_deep100 import vp5::*; (input logic clk);
  al_t   t1, t2, t3, t4;
  al_t   ta [0:1];
  nest_t tn;
  vr_t   tv;
  logic [7:0] r1, r2, r3, r4, r5;
  v5_dflt u_df (.p(t1), .q(t2), .o(r1));
  v5_arr  u_ar (.ap(ta), .np(tn), .vp_(tv), .o(r2));
  v5_if   u_if (.clk(clk));
  generate
    if (1) begin : ga
      al_t g_sig;
      v5_leaf u_g (.p(g_sig), .o(r3));
      assign g_sig = '0;
    end else begin : gb
      al_t g_sig;
      v5_leaf u_g (.p(g_sig), .o(r3));
      assign g_sig = '1;
    end
  endgenerate
  for (genvar gi = 0; gi < 2; gi++) begin : gl
    al_t l_sig;
    v5_leaf u_l (.p(l_sig), .o());
    assign l_sig = '0;
  end
  assign t1 = '0; assign t3 = '0; assign t4 = '0;
  assign tn = '0; assign tv = '0;
  assign ta[0] = '0; assign ta[1] = '0;
  assign r4 = t3.a; assign r5 = t4.b;
endmodule
