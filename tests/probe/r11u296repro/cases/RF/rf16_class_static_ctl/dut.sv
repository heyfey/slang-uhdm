// § retFoldTsKeyedByParam296
package p;
  parameter int A = 3;
  parameter int B = 4;
  class c;
    static function int f(input bit s);
      if (s) return A;
      return B;
    endfunction
  endclass
endpackage
module dut(output int o);
  import p::*;
  initial o = c::f(1'b0);
endmodule
