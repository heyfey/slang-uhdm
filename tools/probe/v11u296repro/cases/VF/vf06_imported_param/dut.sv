// § retFoldTsKeyedByParam296
package q;
  parameter int QA = 11;
endpackage
package p;
  import q::*;
  parameter int B = 4;
  function int f(input bit s);
    if (s) return B;
    return QA;
  endfunction
endpackage
module dut(output int o);
  initial o = p::f(1'b0);
endmodule
