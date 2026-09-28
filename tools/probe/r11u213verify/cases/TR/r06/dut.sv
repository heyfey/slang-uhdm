// § classScopeTdRetBuildsOwner206 (an interface class as the owner; a class typedef naming another package's class)
package q;
  class Q #(type T = int); T v; endclass
endpackage
package p;
  interface class IK;
    typedef q::Q #(logic) q_t;
  endclass
  class K; typedef q::Q #(bit) b_t; endclass
  class B;
    function IK::q_t f(); return null; endfunction
    function K::b_t g(); return null; endfunction
  endclass
endpackage
module r06; endmodule
