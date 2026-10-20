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
  for (genvar i = 0; i < 2; i++) begin : g
    Tr t;
    initial t = new(s[i]);
  end
endmodule
