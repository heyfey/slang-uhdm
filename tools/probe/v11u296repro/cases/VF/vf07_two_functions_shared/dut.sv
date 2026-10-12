// § retFoldTsKeyedByParam296
package p;
  parameter int A = 3;
  parameter int B = 4;
  function int f(input bit s);
    if (s) return A;
    return B;
  endfunction
  function int g(input bit s);
    if (s) return B;
    return A;
  endfunction
endpackage
package r;
  import p::*;
  function int h(); return f(1'b0) + g(1'b1); endfunction
endpackage
module dut(output int o);
  initial o = r::h();
endmodule
