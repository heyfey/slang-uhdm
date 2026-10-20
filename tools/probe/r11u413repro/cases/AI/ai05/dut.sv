// § ifaceArrElemArgBitSel413
interface SBus;
  logic req;
endinterface
module top(output logic o);
  SBus s[2] ();
  assign o = s[1].req;
endmodule
