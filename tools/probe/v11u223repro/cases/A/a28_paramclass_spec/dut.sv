// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  class c #(int N = 1);
    function void f(UVM_FILE x);
    endfunction
  endclass
  class d extends c #(4);
    function void g(UVM_FILE y);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  c #(2) h2;
  c #(3) h3;
  d hd;
endmodule
