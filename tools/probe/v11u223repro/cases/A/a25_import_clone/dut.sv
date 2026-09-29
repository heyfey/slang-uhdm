// § tfArgScalarTdWriter223
package p;
  typedef int UVM_FILE;
  function automatic int inc(UVM_FILE f);
    return f + 1;
  endfunction
endpackage
package q;
  import p::*;
  function automatic int twice(UVM_FILE g);
    return inc(g) + inc(g);
  endfunction
endpackage
module top;
  import q::*;
  import p::*;
  int r;
  initial r = twice(3);
endmodule
