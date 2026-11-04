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
interface bif(input logic clk, output logic w); endinterface
module top;
  import pk::*;
  logic c;
  bif BUS(.clk(c), .w(ww));
  assign z = c;
endmodule
