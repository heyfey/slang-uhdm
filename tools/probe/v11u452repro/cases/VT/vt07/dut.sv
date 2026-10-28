// § thisNetPerListingModule452
package u;
  class C;
    int m_a;
    function void show();
      $display("%p", this);
    endfunction
  endclass
endpackage
package a;
  import u::*;
  class D;
    int m_d;
    function void put();
      $display("%p", this);
    endfunction
  endclass
endpackage
module m1;
  import u::*;
endmodule
module m2;
  import a::*;
endmodule
