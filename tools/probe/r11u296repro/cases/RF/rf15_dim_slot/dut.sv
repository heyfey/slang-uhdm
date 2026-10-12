// § retFoldTsKeyedByParam296
package p;
  parameter int A = 3;
  parameter int B = 4;
  function int f(input bit s);
    if (s) return A;
    return B;
  endfunction
endpackage
module dut(output logic [p::B-1:0] o);
  import p::*;
  logic [7:0] w;
  initial o = w[f(1'b0)-1:0];
endmodule
