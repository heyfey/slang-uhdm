// v100 arm 3 — GENERATE arms, name shadowing, macro double-declaration,
// three instances of one span, interface home.
`define DECLPAIR(NM) al_t NM``_x; al_t NM``_y
package vp3;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } al_t;
  typedef enum logic { Z0, Z1 } z_t;
  typedef struct packed { logic [3:0] c; z_t d; }        vz_t;   // enum member -> VAR
  logic [7:0] shadowme;
endpackage

interface v3_if (input logic clk);
  import vp3::*;
  al_t i_net;
  vz_t i_var;
  modport mp (input i_net, output i_var);
endinterface

// three instances of ONE span; nothing wired -> route fires per instance
module v3_leaf import vp3::*; (input al_t p, output logic [7:0] o);
  assign o = p.a;
endmodule

module v3_gen100 import vp3::*; (input logic clk);

  `DECLPAIR(m1);
  `DECLPAIR(m2);
  al_t shadowme;          // shadows the package variable
  al_t g_a, g_b, g_c;
  logic [7:0] r1, r2, r3;
  v3_leaf u_i1 (.p(g_a), .o(r1));
  v3_leaf u_i2 (.p(g_b), .o(r2));
  v3_leaf u_i3 (.p(g_c), .o(r3));
  generate
    if (1) begin : arm_a
      al_t same_name;      // same name in both arms
      assign same_name = '0;
    end else begin : arm_b
      al_t same_name;
      assign same_name = '1;
    end
  endgenerate
  for (genvar gi = 0; gi < 2; gi++) begin : loop
    al_t per_iter;
    vz_t per_iter_v;
    assign per_iter = '0;
  end
  v3_if u_if (.clk(clk));
  assign g_a = '0; assign g_b = '0; assign g_c = '0;
  assign shadowme = '0;
  assign m1_x = '0; assign m1_y = '0; assign m2_x = '0; assign m2_y = '0;
endmodule
