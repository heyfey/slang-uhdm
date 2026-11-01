// § thisFirstGroupOrigToo456
package u;
  class C;
    int m_a;
    extern task show();
  endclass
  task C::show();
    $display("%p", this);
  endtask
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
  m1 x2();
endmodule
