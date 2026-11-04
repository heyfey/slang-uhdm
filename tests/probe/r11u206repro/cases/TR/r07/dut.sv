// § classScopeTdRetBuildsOwner206
package p;
  class C2;
    int v;
  endclass
  class K;
    typedef C2 c_t;
    typedef K k_t;
  endclass
  class D;
    function K::c_t f1();
      return null;
    endfunction
    function K::k_t f2();
      return null;
    endfunction
  endclass
endpackage
module r07; endmodule
