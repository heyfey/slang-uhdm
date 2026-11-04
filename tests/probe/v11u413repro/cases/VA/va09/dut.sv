// § ifaceArrElemArgBitSel413
interface SBus;
  logic req;
endinterface
class cfg #(type T = int);
  static T store;
  static function void set(T v);
    store = v;
  endfunction
endclass
module top;
  SBus s[2] ();
  initial cfg#(virtual SBus)::set(s[1]);
endmodule
