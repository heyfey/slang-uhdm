// § tfArgScalarTdCallArgFollows231 — a class method call
package p;
  typedef int UVM_FILE;
  class c;
    function int m(UVM_FILE f);
      return f;
    endfunction
  endclass
endpackage
module top(input int a);
  import p::*;
  initial begin
    c h = new;
    int r;
    r = h.m(a);
  end
endmodule
