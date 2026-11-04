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
interface i1;
  import a::*;
endinterface
module m2;
  import u::*;
endmodule
module top;
  i1 x();
  m2 y();
endmodule
