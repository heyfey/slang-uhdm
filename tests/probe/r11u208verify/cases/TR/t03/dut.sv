// § classTdRetSharesTypedefTs200 § classTdRetVarKeepsWrittenLoc202v
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(shortint) q_t;
    function q_t /* block */
        a1();
      return null;
    endfunction
    function q_t // line
        a2();
      return null;
    endfunction
    extern function q_t a3(int k);
  endclass
  `include "body.svh"
endpackage
module t03; endmodule
