// § ifaceArrElemArgBitSel413
interface SBus;
  logic req;
endinterface
module top;
  SBus s[2] ();
  virtual SBus v [2];
  initial begin
    v[0] = s[0];
    v[1] = s[1];
  end
endmodule
