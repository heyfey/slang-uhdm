// § ifaceArrElemArgBitSel413
interface SBus;
  logic req;
endinterface
module top;
  SBus s[2][2] ();
  virtual SBus v;
  initial v = s[1][0];
endmodule
