// § thisNetFlatStreamPlace452
package pk;
  class C;
    int m_z;
    int m_y;
    extern function new();
    extern function int get_y();
  endclass
  function C::new();
    $display("%p", this);
  endfunction
  function int C::get_y();
    return m_y;
  endfunction
endpackage
module top;
  import pk::*;
endmodule
