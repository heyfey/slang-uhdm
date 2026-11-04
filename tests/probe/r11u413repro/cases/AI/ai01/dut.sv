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
  SBus s[1:4] ();
  initial begin
    Tr t[1:4];
    t[1] = new( s[1] );
    t[2] = new(s[3]);
  end
endmodule
