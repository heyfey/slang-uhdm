// § classScopeTdRetBuildsOwner206
package p;
  class C #(type T = int);
    T v;
  endclass
  class K #(int W = 1);
    typedef C #(byte) q_t;
  endclass
  class D;
    function K#(2)::q_t other();
      return null;
    endfunction
  endclass
endpackage
module d01; endmodule
