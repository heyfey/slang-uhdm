// § implicitNetAfterForwarded460 (two instances of the importing module)
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
module mid(input logic x);
  import pk::*;
  child u(.a(x), .b(y));
endmodule
module top;
  logic x;
  mid m0(.x(x));
  mid m1(.x(x));
endmodule
