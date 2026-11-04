// § tfArgScalarTdCallArgFollows231 — two calls of one function from two modules
package p;
  typedef int UVM_FILE;
  function automatic int inc(UVM_FILE f);
    return f + 1;
  endfunction
endpackage
module sub(input int a, output int b);
  import p::*;
  assign b = inc(a);
endmodule
module top(input int a, output int b, output int c);
  import p::*;
  assign b = inc(a);
  sub u(.a(a), .b(c));
endmodule
