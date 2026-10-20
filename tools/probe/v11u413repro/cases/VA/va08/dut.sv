// § ifaceArrElemArgBitSel413
interface SBus;
  logic req;
endinterface
class Tr;
  virtual SBus b;
  function new(virtual SBus s);
    b = s;
  endfunction
endclass
module top;
  SBus s[4] ();
  Tr t;
  initial t = new(s['h2]);
endmodule
