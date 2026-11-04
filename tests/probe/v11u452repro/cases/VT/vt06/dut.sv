// § thisNetPerListingModule452
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
    extern function void put();
  endclass
  function void D::put();
    $display("%p", this);
  endfunction
endpackage
interface i1;
  import u::*;
endinterface
module m2;
  import a::*;
endmodule
module top;
  i1 x();
  m2 y();
endmodule
