// § classScopeTdRetBuildsOwner206 (an extern prototype whose out-of-block body sits in an included file)
package p;
  class C #(type T = int); T v; endclass
  class K; typedef C #(byte) q_t; endclass
  class B;
    extern function K::q_t lookup(int i);
    extern static function K::q_t make();
  endclass
  `include "body.svh"
endpackage
module r04; endmodule
