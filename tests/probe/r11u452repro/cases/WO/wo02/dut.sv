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
package pq;
  import pk::*;
  class D;
    int m_d;
    extern function int get_d();
  endclass
  function int D::get_d();
    return m_d;
  endfunction
endpackage
interface bif; logic clk; endinterface
module slave(interface bus); endmodule
module top;
  import pk::*;
  import pq::*;
  wire w;
  bif BUS();
  slave DUT(.bus(BUS));
endmodule
