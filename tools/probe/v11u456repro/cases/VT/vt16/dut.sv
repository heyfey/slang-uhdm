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
  class D;
    extern function void put();
  endclass
  function void D::put();
    C c;
    c = new;
    $display("%p %p", this, c);
  endfunction
endpackage
module m1;
  import a::*;
endmodule
module m2;
  import a::*;
endmodule
module top;
  m1 x();
  m2 y();
endmodule
