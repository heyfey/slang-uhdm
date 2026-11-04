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
  bif B1();
  bif B2();
  slave D1(.bus(B1));
  slave D2(.bus(B2));
endmodule
