// § memLeftSliceUnlocated169
package p;
  typedef enum int unsigned { M_A = 3, M_B = 9 } m_t;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
    int unsigned C;
  } cfg_t;
  localparam int unsigned PW = 48;
  function automatic cfg_t mk(int unsigned x, int unsigned y);
    cfg_t c;
    c.A = 'h10;
    c.B = unsigned'(y);
    c.C = unsigned'(PW);
    return c;
  endfunction
  localparam cfg_t D = mk(64, 5);
endpackage
module top #(parameter p::cfg_t Cfg = p::D) ();
  leaf #(.W(Cfg.A), .V(Cfg.B), .U(Cfg.C)) u();
endmodule
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1, parameter int unsigned U = 1) (); endmodule
