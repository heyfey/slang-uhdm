// § implicitNetAfterForwarded460 (implicit net named like a class member of the package)
package pk;
  class C;
    int m_a;
    int m_b;
    extern function int get_a();
  endclass
  function int C::get_a();
    return m_a + m_b;
  endfunction
endpackage
module child(input logic a, output logic b); assign b = a; endmodule
module top;
  import pk::*;
  logic x;
  child u(.a(x), .b(m_c));
endmodule
