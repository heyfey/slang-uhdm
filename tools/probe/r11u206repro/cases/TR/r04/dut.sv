// § classScopeTdRetBuildsOwner206
package p2;
  class C #(type T = int);
    T v;
  endclass
  class K;
    typedef C #(byte) q_t;
  endclass
endpackage
package p;
  class D;
    function p2::K::q_t other();
      return null;
    endfunction
  endclass
endpackage
module r04; endmodule
