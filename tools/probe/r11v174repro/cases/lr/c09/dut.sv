// § elabParamLeftoverRefUnnamed174
package p;
  typedef enum logic [1:0] {M0, M1, M2} mode_e;
  typedef struct packed {
    logic [7:0] w;
    logic [3:0] d;
  } in_t;
  typedef struct packed {
    in_t I;
    mode_e M;
    int unsigned A;
  } cfg_t;
  function automatic cfg_t mk(in_t i, mode_e m, int unsigned a);
    cfg_t c;
    c.I = i;
    c.M = m;
    c.A = a;
    return c;
  endfunction
  localparam cfg_t D = mk('{w: 8'd9, d: 4'd2}, M2, 17);
endpackage
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1) (); endmodule
module top #(parameter p::cfg_t Cfg = p::D) ();
  leaf #(.W(Cfg.I.w), .V(Cfg.A)) u();
  if (Cfg.M == p::M2) begin : g
    leaf #(.W(Cfg.I.d)) v();
  end
endmodule
