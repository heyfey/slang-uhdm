// v82 adversarial arm V1 — THE HOME AXIS the implementer's grid never took:
// gen-for, gen-if, nested gen, an interface and a program, at a packed range
// bound naming (a) a non-overridden package int and (b) an OVERRIDDEN module
// parameter whose actual names an expression-initialised localparam.
// MEASUREMENT ONLY.
package pkv1_82;
  localparam int PKA = 8;
  localparam byte PKC = 8;
endpackage

typedef struct packed { logic [3:0] a; } mv1_t;

interface if_v1_82 #(parameter int IW = 1) (input logic clk);
  logic [IW:0]  n_if;
  mv1_t [IW:0]  v_if;
  logic [pkv1_82::PKA:0] n_ifp;
  mv1_t [pkv1_82::PKA:0] v_ifp;
  logic [3:0] u_if [IW:0];
endinterface

program prog_v1_82 #(parameter int PW = 1) (input logic clk);
  logic [PW:0] n_pr;
  mv1_t [PW:0] v_pr;
  logic [pkv1_82::PKA:0] n_prp;
  initial begin
    if (n_pr[0] === 1'b0) $display("%b", v_pr[0].a);
    if (n_prp[0] === 1'b0) $display("x");
  end
endprogram

module child_v1_82 import pkv1_82::*; #(parameter int CW = 1)
  (input logic clk, output logic o);
  logic [CW:0]  n_body;
  mv1_t [CW:0]  v_body;
  logic [PKA:0] n_bodyp;
  mv1_t [PKA:0] v_bodyp;
  logic [3:0]   u_body [CW:0];
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : g_for
      logic [CW:0]  n_gf;
      mv1_t [CW:0]  v_gf;
      logic [PKA:0] n_gfp;
      mv1_t [PKA:0] v_gfp;
      if (gi == 0) begin : g_nest
        logic [CW:0]  n_gn;
        mv1_t [CW:0]  v_gn;
        logic [PKA:0] n_gnp;
        mv1_t [PKA:0] v_gnp;
      end
    end
    if (CW > 0) begin : g_if
      logic [CW:0]  n_gi;
      mv1_t [CW:0]  v_gi;
      logic [PKA:0] n_gip;
      mv1_t [PKA:0] v_gip;
    end
  endgenerate
  if_v1_82 #(.IW(CW)) u_if (.clk(clk));
  assign o = clk ^ n_body[0] ^ v_body[0].a[0] ^ n_bodyp[0] ^ v_bodyp[0].a[0]
             ^ u_body[0][0] ^ g_for[0].n_gf[0] ^ g_for[0].v_gf[0].a[0]
             ^ g_for[0].n_gfp[0] ^ g_for[0].g_nest.n_gn[0]
             ^ g_for[0].g_nest.n_gnp[0] ^ u_if.n_if[0] ^ u_if.n_ifp[0];
endmodule

module top_v1_82 (input logic clk, output logic o1, o2, o3);
  localparam int EXPR_LPV = 4 + 4;   // EXPRESSION init: the pass's own 18 cells
  localparam int LIT_LPV  = 8;       // literal init
  child_v1_82 #(.CW(EXPR_LPV)) ia (.clk(clk), .o(o1));  // overridden, name->expr
  child_v1_82 #(.CW(LIT_LPV))  ib (.clk(clk), .o(o2));  // overridden, name->literal
  child_v1_82                  ic (.clk(clk), .o(o3));  // NOT overridden
  prog_v1_82 #(.PW(EXPR_LPV)) i_pr (.clk(clk));
endmodule
