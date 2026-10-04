// § tfArgScalarTdCallArgFollows231 — an explicitly imported scalar typedef on a module function formal (v11u223 a12)
package p;
  typedef int UVM_FILE;
endpackage
module top(input int a, output int o);
  import p::UVM_FILE;
  function automatic int h(UVM_FILE z);
    return z;
  endfunction
  assign o = h(a);
endmodule
