// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  function automatic int inc(UVM_FILE f);
    return f + 1;
  endfunction
endpackage
module top(input int a, output int b, output int c);
  import p::*;
  assign b = inc(a);
  assign c = p::inc(a);
endmodule
