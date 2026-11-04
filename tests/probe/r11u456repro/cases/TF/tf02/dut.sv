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
    int m_d;
  endclass
endpackage
module m0;
  logic q;
endmodule
module m1;
  import a::*;
endmodule
module m2;
  import u::*;
endmodule
module m3;
  import u::*;
endmodule
module top;
  m0 w();
  m1 x();
  m2 y();
  m3 z();
endmodule
