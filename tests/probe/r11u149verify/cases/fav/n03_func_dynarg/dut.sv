// § foreachArrayPlaceholderFile140
package p;
  function automatic int sum(int d[]);
    int s = 0;
    foreach (d[j]) s += d[j];
    return s;
  endfunction
endpackage
module dut;
  int r;
  initial r = p::sum('{1, 2});
endmodule
