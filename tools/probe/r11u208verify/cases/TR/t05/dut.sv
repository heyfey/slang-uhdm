// § classTdRetSharesTypedefTs200 § classTdRetVarKeepsWrittenLoc202v
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(int) q_t;
    function q_t
        a1();
      return null;
    endfunction
    function K::q_t a2(); return null; endfunction
  endclass
endpackage
module t05; endmodule
