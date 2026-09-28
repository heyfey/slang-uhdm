// § classTdRetSharesTypedefTs200
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
    static function q_t mk();
      return null;
    endfunction
  endclass
  class D extends K;
    function q_t mk2();
      return null;
    endfunction
    function p::K::q_t mk3();
      return null;
    endfunction
  endclass
endpackage
module q04; endmodule
