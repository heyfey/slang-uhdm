// § retFoldTsKeyedByParam296
package p;
  parameter logic [7:0] A = 8'h3;
  parameter logic [3:0] B = 4'h4;
  function logic [7:0] f(input bit s);
    if (s) return A;
    return B;
  endfunction
endpackage
module dut(output logic [7:0] o);
  import p::*;
  initial o = f(1'b0);
endmodule
