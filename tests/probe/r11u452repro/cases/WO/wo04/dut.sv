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
interface bif; logic clk; endinterface
module slave(interface bus); endmodule
module top;
  import pk::*;
  bif BUS();
  bif BUS2();
  slave DUT(.bus(BUS));
  slave DUT2(.bus(BUS2));
endmodule
