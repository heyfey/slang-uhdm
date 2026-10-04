// § tfArgScalarTdCallArgFollows231 — c01 with CRLF line ends
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
