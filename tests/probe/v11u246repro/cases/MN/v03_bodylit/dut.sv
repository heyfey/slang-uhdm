// § macroParamMethNameEnd246
`define CMP(A) A = obj.compute(A, 1) + obj.nm(1);
`define SZ(Q) n = Q.size(); Q.delete();
package p;
  class worker;
    function int compute(int a, int b); return a + b; endfunction
    function int nm(int a); return a; endfunction
  endclass
  class user;
    worker obj;
    int qq[$];
    function void go();
      int very_long_variable_name;
      int n;
      `CMP(very_long_variable_name)
      `SZ(qq)
    endfunction
  endclass
endpackage
module top;
endmodule
