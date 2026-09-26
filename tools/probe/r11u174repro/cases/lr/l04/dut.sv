// § elabParamLeftoverRefUnnamed174
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    int unsigned C;
  } cfg_t;
  function automatic cfg_t mk(int unsigned x, int unsigned y);
    cfg_t c;
    c.A = x;
    c.B = y;
    c.C = 7;
    return c;
  endfunction
  localparam int unsigned PW = 48;
  localparam cfg_t D = mk(64, 5);
  localparam cfg_t E = mk(PW, 3);
endpackage
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1, parameter int unsigned U = 1) (); endmodule
module top #(parameter p::cfg_t Cfg = p::E) ();
  leaf #(.W(Cfg.A), .V(Cfg.B)) u();
endmodule
