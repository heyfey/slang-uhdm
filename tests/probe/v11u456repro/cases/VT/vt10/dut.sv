// § thisFirstGroupOrigToo456
package u;
  class C;
    int m_a;
    extern function void show();
  endclass
  function void C::show();
    $display("%p", this);
  endfunction
endpackage
package a;
  import u::*;
  class D extends C;
    function void z(); $display("%p", this); endfunction
  endclass
endpackage
module m1;
  import a::*;
endmodule
module m2;
  import u::*;
endmodule
module top;
  m1 x();
  m2 y();
endmodule
