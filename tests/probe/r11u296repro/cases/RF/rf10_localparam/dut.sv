// § retFoldTsKeyedByParam296
package p;
  localparam int A = 3;
  localparam int B = A + 1;
  function int f(input bit s);
    if (s) return A;
    return B;
  endfunction
endpackage
module dut(output int o);
  import p::*;
  initial o = f(1'b0);
endmodule
