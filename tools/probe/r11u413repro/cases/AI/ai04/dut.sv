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
  localparam P = 1;
  SBus s[0:1] ();
  Tr t;
  initial t = new(s[P]);
endmodule
