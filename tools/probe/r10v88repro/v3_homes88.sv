// r10v88 v3 — ADVERSARIAL: homes (3-deep chain, gen-for, gen-if, interface,
// 1-3 instances) x the two element structs.  MEASUREMENT ONLY.
package t88;
  typedef struct packed { logic a; logic [3:0] b; }        f_t;   // STRICT 1
  typedef struct packed { struct packed { logic q; } e; logic c; } n_t; // STRICT 0
endpackage

module vlvl_a (input t88::f_t [1:0] a_f, input t88::n_t [1:0] a_n,
               output t88::n_t [1:0] a_no);
  t88::n_t [1:0] body_n;
  t88::f_t [1:0] body_f;
endmodule

module vlvl_b (input t88::f_t [1:0] b_f, input t88::n_t [1:0] b_n);
  t88::n_t [1:0] body_n;
  vlvl_a u_a0 (.a_f(b_f), .a_n(b_n), .a_no());
  vlvl_a u_a1 (.a_f(b_f), .a_n(body_n), .a_no());
endmodule

module vlvl_c (input t88::f_t [1:0] c_f, input t88::n_t [1:0] c_n);
  vlvl_b u_b (.b_f(c_f), .b_n(c_n));
endmodule

interface vif3 (input t88::n_t [1:0] if_port_n);
  t88::n_t [1:0] if_body_n;
  t88::f_t [1:0] if_body_f;
endinterface

module vgen (input t88::n_t [1:0] g_n, input t88::f_t [1:0] g_f);
  t88::n_t [1:0] g_body_n;
endmodule

module vtop3;
  t88::f_t [1:0] tw_f;  t88::n_t [1:0] tw_n;
  t88::n_t [1:0] tw_n_body;
  vlvl_c u_c0 (.c_f(tw_f), .c_n(tw_n));
  vlvl_c u_c1 (.c_f(tw_f), .c_n(tw_n));
  vlvl_c u_c2 (.c_f(tw_f), .c_n(tw_n));
  vif3   u_if (.if_port_n(tw_n));
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gb
      t88::n_t [1:0] gs_n;
      t88::f_t [1:0] gs_f;
      vgen u_g (.g_n(gs_n), .g_f(gs_f));
    end
    if (1) begin : gif
      t88::n_t [1:0] gi_n;
      vgen u_gi (.g_n(gi_n), .g_f(tw_f));
    end
  endgenerate
endmodule
