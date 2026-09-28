// § classScopeTdRetBuildsOwner206
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
  endclass
  class Z;
    function K::q_t g();
      return null;
    endfunction
  endclass
endpackage
module d08; endmodule
