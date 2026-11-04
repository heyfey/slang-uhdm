// § classScopeTdRetBuildsOwner206
package p;
  class C #(type T = int);
    T v;
  endclass
  class Z;
    typedef C #(int) t_t;
  endclass
  class E extends Z;
    function t_t f();
      return null;
    endfunction
  endclass
endpackage
module r05; endmodule
