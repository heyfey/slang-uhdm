// r10earl53 VERIFIER arm v3 — generate scopes, instance arrays, interfaces,
// instance PARAMETER actuals, and the DEF-view fence, all carrying member paths.
package pv3_v53;
  typedef struct packed { logic [2:0] op; logic [1:0] pr; } inner_t;
  typedef struct packed { inner_t i; logic [3:0] w; } outer_t;
  typedef struct packed { logic [1:0] e0; logic [1:0] e1; } el_t;
endpackage

interface ifv3_v53;
  pv3_v53::outer_t  st;
  logic [2:0]       sig;
  modport mp (input st, input sig);
endinterface

module sinkv3_v53 #(parameter int W = 8) (input logic [W-1:0] d, output logic [W-1:0] q);
  assign q = d;
endmodule

module midv3_v53 (ifv3_v53.mp itf, output logic [4:0] q_o);
  // a member path whose ROOT is a MODPORT-qualified interface port
  sinkv3_v53 #(.W(3)) u_ifm (.d(itf.st.i.op), .q(q_o[2:0]));
  sinkv3_v53 #(.W(2)) u_ifs (.d(itf.sig[1:0]), .q(q_o[4:3]));
endmodule

module genv3_v53 #(parameter int G = 0) (input pv3_v53::outer_t o_i, output logic [3:0] z);
  logic [3:0] n;
  sinkv3_v53 #(.W(4)) u_g (.d(o_i.w), .q(n));
  assign z = n ^ G[3:0];
endmodule

module v3_v53 #(parameter int N = 3) (
  input  pv3_v53::outer_t o_i,
  input  pv3_v53::el_t    e_i,
  output logic [63:0]     z_o
);
  logic [4:0] n_if;
  logic [3:0] n_g [0:2];
  logic [3:0] n_ifg;
  logic [1:0] n_arr [0:2];
  logic [2:0] n_cond;

  ifv3_v53 itf_i ();
  midv3_v53 u_mid (.itf(itf_i.mp), .q_o(n_if));

  // generate FOR: each iteration's conn actual is the SAME written path
  generate
    for (genvar gi = 0; gi < N; gi++) begin : g_loop
      genv3_v53 #(.G(gi)) u_gl (.o_i(o_i), .z(n_g[gi]));
    end
    if (N == 3) begin : g_cond
      sinkv3_v53 #(.W(4)) u_gc (.d({o_i.i.op, o_i.i.pr[0]}), .q(n_ifg));
    end
  endgenerate

  // instance ARRAY whose actual is a member path
  sinkv3_v53 #(.W(2)) u_arr [0:2] (.d(e_i.e0), .q(n_arr));

  // an instance PARAMETER actual that references a struct member of a PARAM
  localparam pv3_v53::outer_t PO = '{i: '{op: 3'd5, pr: 2'd1}, w: 4'd9};
  sinkv3_v53 #(.W(3)) u_pm (.d(3'(PO.i.op)), .q(n_cond));

  assign z_o = {n_if, n_g[0], n_g[1], n_g[2], n_ifg, n_arr[0], n_arr[1],
                n_arr[2], n_cond, 32'b0};
endmodule
