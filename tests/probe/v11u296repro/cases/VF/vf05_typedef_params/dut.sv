// § retFoldTsKeyedByParam296
package p;
  typedef logic [5:0] w_t;
  parameter w_t A = 6'd3;
  parameter w_t B = 6'd9;
  function w_t f(input bit s);
    if (s) return A;
    return B;
  endfunction
endpackage
module dut(output logic [5:0] o);
  import p::*;
  assign o = f(1'b1);
endmodule
