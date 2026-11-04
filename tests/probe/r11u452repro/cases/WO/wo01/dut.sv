// § ifaceConnNetAfterForwarded452
package pk;
  class C;
    int m_a;
    int m_b;
    extern function int get_a();
    extern function void show();
    extern function int get_b();
  endclass
  function int C::get_a();
    return m_a;
  endfunction
  function void C::show();
    $display("%p", this);
  endfunction
  function int C::get_b();
    return m_b;
  endfunction
endpackage
interface bif; logic clk; endinterface
module slave(interface bus); endmodule
module top;
  import pk::*;
  bif BUS();
  slave DUT(.bus(BUS));
endmodule
