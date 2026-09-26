// § memLeftFormalArgLoc169
`define MK mk(64, 5)
`define XW 64
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    int unsigned C;
  } cfg_t;
  localparam int unsigned PW = 48;
  function automatic cfg_t mk(int unsigned x = 16, int unsigned y = 5);
    cfg_t c;
    c.A = x;
    c.B = x / 8;
    c.C = y;
    return c;
  endfunction
  localparam cfg_t D = mk(32'h40, 5);
endpackage
module top #(parameter p::cfg_t Cfg = p::D) ();
  leaf #(.W(Cfg.A), .V(Cfg.B), .U(Cfg.C)) u();
endmodule
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1, parameter int unsigned U = 1) (); endmodule
