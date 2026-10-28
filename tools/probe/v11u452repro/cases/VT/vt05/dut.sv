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
package b;
  import a::*;
  class E;
    int m_e;
    extern function void get();
  endclass
  function void E::get();
    $display("%p", this);
  endfunction
endpackage
module m1;
  import u::*;
endmodule
module m2;
  import a::*;
endmodule
module m3;
  import b::*;
endmodule
