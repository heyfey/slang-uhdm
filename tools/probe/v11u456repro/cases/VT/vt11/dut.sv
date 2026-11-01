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
program p1;
  import a::*;
endprogram
module m2;
  import u::*;
endmodule
module top;
  p1 x();
  m2 y();
endmodule
