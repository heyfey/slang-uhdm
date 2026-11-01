// § implicitNetAfterForwarded460 (implicit nets interleaved with declared nets)
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
  child u1(.a(x), .b(y1));
  logic z;
  child u2(.a(z), .b(y2));
  assign k = y1;
endmodule
