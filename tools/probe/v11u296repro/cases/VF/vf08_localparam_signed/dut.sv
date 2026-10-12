// § retFoldTsKeyedByParam296
package p;
  localparam int signed A = -3;
  localparam int unsigned B = 4;
  function int f(input bit s);
    if (s) return A;
    return B;
  endfunction
endpackage
module dut(output int o);
  initial o = p::f(1'b1);
endmodule
