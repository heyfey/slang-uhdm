// § ifaceConnNetAfterForwarded452
package pk;
  int g_v;
  class C;
    int m_a;
    extern function int get_a();
    extern function void show();
  endclass
  function int C::get_a();
    return m_a;
  endfunction
  function void C::show();
    $display("%p", this);
  endfunction
endpackage
interface bif; logic clk; endinterface
module slave(interface bus); endmodule
module top;
  import pk::*;
  bif BUS();
  slave DUT(.bus(BUS));
  initial $dumpvars(0, top);
endmodule
