// § thisFirstGroupOrigToo456
package u;
  class C;
    int m_a;
    extern function void show();
  endclass
  class E extends C;
    extern function void more();
  endclass
  function void C::show();
    $display("%p", this);
  endfunction
  function void E::more();
    this.m_a = 3;
    $display("%p", this);
  endfunction
endpackage
package a;
  import u::*;
  int k;
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
