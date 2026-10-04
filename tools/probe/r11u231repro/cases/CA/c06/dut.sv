// § tfArgScalarTdCallArgFollows231 — a call inside a package function body
package p;
  typedef int UVM_FILE;
  function automatic int inner(UVM_FILE f);
    return f * 2;
  endfunction
  function automatic int outer(int v);
    UVM_FILE g;
    g = v;
    return inner(g);
  endfunction
endpackage
module top(input int a, output int o);
  assign o = p::outer(a);
endmodule
