// § classTdRetSharesTypedefTs200 § classTdRetVarKeepsWrittenLoc202v
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(int) q_t;
  endclass
endpackage
package r;
  class D;
    function p::K::q_t get();
      return null;
    endfunction
    static function p::K::q_t sget();
      p::K::q_t loc;
      return loc;
    endfunction
  endclass
endpackage
module t01; endmodule
