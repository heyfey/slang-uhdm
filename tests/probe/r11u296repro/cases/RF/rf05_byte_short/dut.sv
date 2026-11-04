// § retFoldTsKeyedByParam296
package p;
  parameter byte A = 3;
  parameter shortint B = 4;
  function int f(input bit s);
    if (s) return A;
    return B;
  endfunction
endpackage
module dut(output int o);
  import p::*;
  initial o = f(1'b0);
endmodule
