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
  logic x;
  bif BUS();
  wire y;
  slave DUT(.bus(BUS));
  initial $dumpvars(0, top);
endmodule
