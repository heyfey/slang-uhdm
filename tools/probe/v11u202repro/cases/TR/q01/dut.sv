// § classTdRetSharesTypedefTs200
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
  endclass
  class D;
    function K::q_t lookup(string s);
      return null;
    endfunction
  endclass
endpackage
module q01; endmodule
