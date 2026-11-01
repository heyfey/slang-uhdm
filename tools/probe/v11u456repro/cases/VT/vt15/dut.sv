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
module m1;
  import a::*;
endmodule
interface i2;
  import u::*;
endinterface
module top;
  m1 x();
  i2 y();
endmodule
