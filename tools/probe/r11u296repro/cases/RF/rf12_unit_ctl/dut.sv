// § retFoldTsKeyedByParam296
parameter int A = 3;
parameter int B = 4;
function int f(input bit s);
  if (s) return A;
  return B;
endfunction
module dut(output int o);
  initial o = f(1'b0);
endmodule
