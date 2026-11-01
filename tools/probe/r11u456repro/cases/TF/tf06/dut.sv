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
    int k;
  endclass
endpackage
package b;
  import a::*;
  class E;
    extern function void go();
  endclass
  function void E::go();
    $display("%p", this);
  endfunction
endpackage
module m1;
  import b::*;
endmodule
module m2;
  import a::*;
endmodule
module top;
  m1 x();
  m2 y();
endmodule
