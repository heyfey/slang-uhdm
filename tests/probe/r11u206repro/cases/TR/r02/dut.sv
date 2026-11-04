// § classScopeTdRetBuildsOwner206
package p;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
  endclass
  class D;
    function K::q_t
        other();
      return null;
    endfunction
  endclass
endpackage
module r02; endmodule
