// § retFoldTsKeyedByParam296
package p;
  parameter int A = 3;
  parameter int B = 4;
  function int f();
    int q;
    q = 1;
    if (q == 0) return B;
    return A;
  endfunction
endpackage
module dut(output int o);
  import p::*;
  initial o = f();
endmodule
