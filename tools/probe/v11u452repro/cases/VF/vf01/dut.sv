// § thisNetFlatStreamPlace452
package pk;
  int p;
  class C;
    int m_z;
    int m_y;
    extern function int get_z();
    extern function void show();
  endclass
  function int C::get_z();
    return m_z + p;
  endfunction
  function void C::show();
    $display("%p", this);
  endfunction
endpackage
module top;
  import pk::*;
endmodule
