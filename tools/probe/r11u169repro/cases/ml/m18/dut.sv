// § memLeftSliceUnlocated169
package p;
  typedef struct packed { int unsigned S; int unsigned T; } u_t;
  typedef struct packed { int unsigned A; int unsigned B; } cfg_t;
  localparam u_t U = '{S: 8, T: 3};
  function automatic cfg_t mk(u_t u);
    cfg_t c;
    c.A = u.S * 2;
    c.B = 7;
    return c;
  endfunction
  localparam cfg_t D = mk(U);
endpackage
module top #(parameter p::cfg_t Cfg = p::D) ();
  leaf #(.W(Cfg.A), .V(Cfg.B)) u();
endmodule
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1) (); endmodule
