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
  SBus s[2] ();
  virtual SBus v;
  initial begin
    v = s[1];
  end
endmodule
