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
    extern task put();
  endclass
  task D::put();
    $display("%p", this.m_d);
  endtask
endpackage
module m1;
  import u::*;
endmodule
module m2;
  import a::*;
endmodule
module m3;
  import a::*;
endmodule
