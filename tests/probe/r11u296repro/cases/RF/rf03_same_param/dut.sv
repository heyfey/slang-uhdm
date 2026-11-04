// § retFoldTsKeyedByParam296
package p;
  parameter int A = 3;
  parameter int B = 4;
  function int f(input bit s);
    if (s) return A;
    return A;
  endfunction
endpackage
module dut(output int o);
  import p::*;
  initial o = f(1'b1) + B;
endmodule
