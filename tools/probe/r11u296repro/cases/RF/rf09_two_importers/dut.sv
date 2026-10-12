// § retFoldTsKeyedByParam296
package p;
  parameter int A = 3;
  parameter int B = 4;
  function int f(input bit s);
    if (s) return A;
    return B;
  endfunction
  function int h(input bit s);
    if (s) return B;
    return A;
  endfunction
endpackage
package q1;
  import p::*;
  function int g1(); return f(1'b0) + h(1'b1); endfunction
endpackage
package q2;
  import p::*;
  function int g2(); return h(1'b0); endfunction
endpackage
module dut(output int o);
  import q1::*;
  import q2::*;
  initial o = g1() + g2();
endmodule
