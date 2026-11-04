// § implicitNetAfterForwarded460
package pk;
  class C;
    int m_a;
    int m_b;
    extern function int get_a();
    extern function int get_b();
  endclass
  function int C::get_a();
    return m_a;
  endfunction
  function int C::get_b();
    return m_b;
  endfunction
endpackage
module top;
  import pk::*;
  logic x;
  assign y = x;
endmodule
