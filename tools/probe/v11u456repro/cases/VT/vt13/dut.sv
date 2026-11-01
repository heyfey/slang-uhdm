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
module m2;
  import u::*;
endmodule
module m1;
  import a::*;
endmodule
module top;
  m2 y();
  m1 x();
endmodule
