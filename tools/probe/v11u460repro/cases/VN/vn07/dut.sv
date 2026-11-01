// § implicitNetAfterForwarded460 (interface importing the package with an implicit net)
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
interface ifc(input logic x);
  import pk::*;
  assign iy = x;
endinterface
module top;
  logic x;
  ifc i(.x(x));
endmodule
