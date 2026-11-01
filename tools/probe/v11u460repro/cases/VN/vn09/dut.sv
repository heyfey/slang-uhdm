// § implicitNetAfterForwarded460 (implicit nets in a child that imports, the parent without imports)
package pk;
  class C;
    int m_a;
    extern function int get_a();
  endclass
  function int C::get_a();
    return m_a;
  endfunction
endpackage
module child(input logic a, output logic b); assign b = a; endmodule
module mid(input logic i, output logic o);
  import pk::*;
  child u(.a(i), .b(w));
  assign o = w;
endmodule
module top;
  logic x;
  mid m(.i(x), .o(y));
endmodule
