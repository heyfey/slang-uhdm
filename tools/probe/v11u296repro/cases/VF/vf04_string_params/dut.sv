// § retFoldTsKeyedByParam296
package p;
  parameter string A = "ab";
  parameter string B = "cde";
  function string f(input bit s);
    if (s) return A;
    return B;
  endfunction
endpackage
module dut;
  string o;
  initial o = p::f(1'b0);
endmodule
