// § multiDeclOneItem140
package p;
  function automatic int g(input int v);
    int m, n;
    m = v;
    n = m + 1;
    return n;
  endfunction
endpackage
module dut(input int a, output int y);
  assign y = p::g(a);
endmodule
