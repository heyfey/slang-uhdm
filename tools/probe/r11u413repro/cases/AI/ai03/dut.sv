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
  SBus s[0:1] ();
  function automatic void f(virtual SBus x); endfunction
  initial f(s[0]);
endmodule
