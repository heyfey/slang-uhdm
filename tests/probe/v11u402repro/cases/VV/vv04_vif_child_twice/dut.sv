// § vifVarNotElaborated402
interface I; logic a; endinterface
module child;
  virtual I v;
endmodule
module top;
  child c1();
  child c2();
endmodule
