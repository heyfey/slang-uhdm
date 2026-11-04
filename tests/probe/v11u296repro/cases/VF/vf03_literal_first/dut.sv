// § retFoldTsKeyedByParam296
package p;
  parameter int A = 3;
  parameter int B = 4;
  function int f(input int s);
    if (s == 2) return 7;
    if (s == 1) return A;
    return B;
  endfunction
endpackage
module dut(output int o);
  initial o = p::f(1);
endmodule
