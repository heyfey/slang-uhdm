// § ifaceArrElemArgBitSel413
interface SBus;
  logic req;
endinterface
module top;
  SBus s[4] ();
  virtual SBus v;
  function automatic virtual SBus pick(virtual SBus a);
    return a;
  endfunction
  initial v = pick(s[3]);
endmodule
