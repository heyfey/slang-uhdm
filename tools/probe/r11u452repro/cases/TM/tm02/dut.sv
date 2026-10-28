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
    extern function void get();
  endclass
  function void D::put();
    $display("%p", this);
  endfunction
  function void D::get();
    $display("%p", this);
  endfunction
endpackage
package b;
  import u::*;
  import a::*;
  class F;
    extern function void own();
  endclass
  function void F::own();
    $display("%p", this);
  endfunction
endpackage
module m1;
  import u::*;
endmodule
module m2;
  import u::*;
  import b::*;
endmodule
