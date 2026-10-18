// § vifVarNotElaborated402
interface I; logic a; modport mp(input a); endinterface
module top;
  virtual I.mp v;
endmodule
