// § opIdxRecvElemFollowsPath215 — calls inside the operation index (as operand, as nested argument) and a unary index with a call
package p;
  class fld;
    function int get(); return 0; endfunction
  endclass
  function automatic int g(int x); return x; endfunction
  class reg_c;
    fld fields[$];
    function int f(int i);
      int a;
      a = fields[g(i-1)+1].get();
      a = fields[-g(i)].get();
      a = fields[i-g(1)].get();
      return a;
    endfunction
  endclass
endpackage
module m;
endmodule
