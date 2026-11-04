// § retFoldTsKeyedByParam296
package p;
  parameter int A = 3;
  parameter int B = 4;
  parameter int C = 5;
  function int f(input bit [1:0] s);
    case (s)
      2'd0: return A;
      2'd1: return C;
      default: ;
    endcase
    return B;
  endfunction
endpackage
module dut(output int o);
  import p::*;
  initial o = f(2'd2);
endmodule
