// § retFoldTsKeyedByParam296
package p;
  parameter int A = 3;
  parameter int B = 4;
  function void v(); return; endfunction
  function int f(input bit s);
    if (s) begin
      return A;
    end
    return B;
  endfunction
endpackage
module dut(output int o);
  import p::*;
  initial v();
  initial o = f(1'b0);
endmodule
