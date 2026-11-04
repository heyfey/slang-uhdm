// § thisFirstGroupOrigToo456
package u;
  class C;
    int m_a;
    extern function void show();
    function void inb(); $display("%p", this); endfunction
  endclass
  function void C::show();
    $display("%p", this);
    this.m_a = 1;
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
