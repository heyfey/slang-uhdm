// § ifaceConnNetAfterForwarded452
package pk;
  class C;
    int m_a;
    extern function int get_a();
  endclass
  function int C::get_a();
    return m_a;
  endfunction
endpackage
interface bif; logic clk; modport mp(input clk); endinterface
module slave(bif.mp bus); endmodule
module top;
  import pk::*;
  bif BUS();
  slave DUT(.bus(BUS));
endmodule
