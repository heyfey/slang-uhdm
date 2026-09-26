// § memLeftSliceUnlocated169 § memLeftFormalArgLoc169
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    int unsigned C;
  } cfg_t;
  localparam int unsigned PW = 48;
  function automatic int unsigned sq(int unsigned v); return v * v; endfunction
  function automatic cfg_t mk(int unsigned x, int unsigned y);
    cfg_t c;
    c.A = unsigned'('d3);
    c.B = x / 8;
    c.C = signed'(8'sh7F);
    return c;
  endfunction
  localparam cfg_t D = mk(64, 5);
endpackage
module top #(parameter p::cfg_t Cfg = p::D) ();
  leaf #(.W(Cfg.A), .V(Cfg.B), .U(Cfg.C)) u();
endmodule
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1, parameter int unsigned U = 1) (); endmodule
