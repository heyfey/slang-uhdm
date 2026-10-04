// § tfArgScalarTdCallArgFollows231 — arguments that are expressions and literals beside a plain name
package p;
  typedef int UVM_FILE;
endpackage
module top(input int a, output int o, output int o2);
  import p::UVM_FILE;
  function automatic int h(UVM_FILE z, int k);
    return z + k;
  endfunction
  assign o = h(a, a);
  assign o2 = h(a, a + 1);
endmodule
