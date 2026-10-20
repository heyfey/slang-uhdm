// § ifaceArrElemArgBitSel413
interface SBus;
  logic req;
endinterface
module sub(SBus p [2]);
  virtual SBus v;
  initial v = p[1];
endmodule
module top;
  SBus s[2] ();
  sub u(.p(s));
endmodule
