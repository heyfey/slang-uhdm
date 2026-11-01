// § implicitNetAfterForwarded460 (implicit net in a generate block of the importing module)
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
  if (1) begin : g
    child u(.a(x), .b(gy));
  end
  child v(.a(x), .b(ty));
endmodule
