// § classScopeTdRetBuildsOwner206 (residue check: K#(.W(2))::q_t, the own-package-qualified p::K::q_t)
package p;
  class C #(type T = int); T v; endclass
  class K #(int W = 1); typedef C #(byte) q_t; endclass
  class J; typedef C #(int) r_t; endclass
  class B;
    function K#(.W(2))::q_t f(); return null; endfunction
    function p::J::r_t g(); return null; endfunction
  endclass
endpackage
module r05; endmodule
