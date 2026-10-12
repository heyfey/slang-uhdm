// § retFoldTsKeyedByParam296
package p;
  parameter int A = 3;
  parameter int B = 4;
  parameter int D = 5;
  function int f(input int s);
    if (s == 0) return A;
    if (s == 1) return B;
    if (s == 2) return A;
    return D;
  endfunction
endpackage
module dut(output int o);
  import p::*;
  initial o = f(1);
endmodule
