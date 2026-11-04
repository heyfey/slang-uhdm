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
    $display("%p", this);
  endfunction
endpackage
package b;
  import u::*;
  class E;
    int k;
  endclass
endpackage
module m1;
  import a::*;
  import b::*;
endmodule
module m2;
  import u::*;
endmodule
module top;
  m1 x();
  m2 y();
endmodule
