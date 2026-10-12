// § retFoldTsKeyedByParam296
package p;
  parameter int A = 3;
  parameter int B = 4;
  function int f(input int n);
    for (int i = 0; i < n; i++) return A;
    return B;
  endfunction
endpackage
module dut(output int o);
  import p::*;
  initial o = f(0);
endmodule
