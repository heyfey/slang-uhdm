// § thisFirstGroupOrigToo456
package u;
  class C;
    int m_a;
    extern function void show();
    extern function void put();
  endclass
  function void C::show();
    $display("%p", this);
  endfunction
  function void C::put();
    this.m_a = 2;
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
module m3;
  import a::*;
endmodule
module top;
  m1 x();
  m2 y();
  m3 z();
endmodule
