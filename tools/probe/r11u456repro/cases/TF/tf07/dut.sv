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
    function void put();
      $display("%p", this);
    endfunction
  endclass
endpackage
module m1;
  import a::*;
  initial begin end
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
