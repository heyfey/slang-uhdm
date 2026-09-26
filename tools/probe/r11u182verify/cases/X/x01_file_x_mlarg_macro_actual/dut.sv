// § tdMoveCarriesFile172 § memLeftFormalArgLoc169 § mlArgLocFileAtActual177v
module leaf #(parameter int unsigned W = 1, parameter int unsigned V = 1) (); endmodule
module top #(parameter p::cfg_t C = p::D) ();
  leaf #(.W(C.A), .V(C.B)) u();
endmodule
