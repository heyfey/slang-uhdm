// § tfItemLocalSpecAtName209: a package-qualified specialization in an out-of-body paren-less method
package p;
  class k #(int W = 1);
  endclass
  class c;
    extern function void g;
  endclass
  function void c::g;
    p::k #(4) d;
    k #(6) f;
  endfunction
endpackage
module top;
endmodule
