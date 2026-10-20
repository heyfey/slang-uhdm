// § ifaceArrElemArgBitSel413
interface SBus;
  logic req;
endinterface
module top;
  SBus s[4] ();
  virtual SBus v;
  always @* v <= s[1];
endmodule
