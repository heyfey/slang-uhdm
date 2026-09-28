// § classScopeTdRetBuildsOwner206 (the owner class nested inside the returning class)
package p;
  class C #(type T = int); T v; endclass
  class D;
    class K; typedef C #(byte) q_t; endclass
    function K::q_t f(); return null; endfunction
  endclass
endpackage
module r03; endmodule
