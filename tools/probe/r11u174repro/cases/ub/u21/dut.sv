// § elabStructMemberOpFoldUnlocated174
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
  } cfg_t;
  localparam cfg_t PD = '{A: 64, B: 5};
endpackage
module leaf #(parameter int unsigned W = 1) (); endmodule
module top #(parameter p::cfg_t Cfg = p::PD,
  localparam int X = Cfg.A / Cfg.B) ();
  leaf #(.W(X)) u();
endmodule
