// § ifaceArrElemArgBitSel413
interface SBus;
  logic req;
endinterface
module top;
  SBus s[2] ();
  virtual SBus v;
  initial begin
    v = s[0];
    v.req = 0;
  end
endmodule
