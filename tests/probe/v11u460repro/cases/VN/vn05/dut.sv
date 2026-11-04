// § implicitNetAfterForwarded460 (non-ANSI port beside an implicit net)
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
module top(p);
  import pk::*;
  input p;
  child u(.a(p), .b(y));
endmodule
