// § thisNetFirstListingModule418
package p;
  class c;
    int v;
    extern function void f1();
  endclass
  function void c::f1();
    $display("%p", this);
  endfunction
endpackage
module sub (input logic a);
  import p::*;
endmodule
module top;
  import p::*;
  logic x;
  sub u (.a(x));
endmodule
