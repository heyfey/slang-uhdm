// § thisFirstGroupOrigToo456
package u;
  class C #(int N = 2);
    int m_a;
    extern function void show();
  endclass
  function void C::show();
    $display("%p %0d", this, N);
  endfunction
endpackage
package a;
  import u::*;
  int k;
endpackage
module m1;
  import a::*;
endmodule
module top;
  m1 x();
endmodule
