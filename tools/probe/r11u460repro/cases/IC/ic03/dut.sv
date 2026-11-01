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
module child(input logic a, output logic b); assign b = a; endmodule
module top;
  import pk::*;
  logic x;
  child u1(.a(x), .b(y1));
  child u2(.a(y1), .b(y2));
  child u3[1:0](.a(x), .b(y3));
endmodule
