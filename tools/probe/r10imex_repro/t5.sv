// t5 — name-MATCHED generic interface port with a PLAIN (non-modport)
// connection: does the var-doubling law (boundToPlainGenericIfacePort) fire?
interface I;
logic [7:0] r;
bit R;
modport A (output R);
endinterface

module pp (interface I);        // plain connection, positional
  initial I.R = 1'b0;
endmodule

module pn (interface I);        // plain connection, by name
  initial I.R = 1'b0;
endmodule

module top();
  I inst();
  pp u_pp (inst);
  pn u_pn (.I(inst));
endmodule
