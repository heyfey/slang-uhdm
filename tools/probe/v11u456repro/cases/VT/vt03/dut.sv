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
  int k;
endpackage
package b;
  import u::*;
  int j;
endpackage
module m1;
  import a::*;
endmodule
module m2;
  import b::*;
endmodule
module top;
  m1 x();
  m2 y();
endmodule
