// vsd11 v6 — $unit SCOPE.  The claim table walks compilation units at GROUP 0
// with an EMPTY container name, and registers a $unit class as `work@<name>`.
// A $unit typedef therefore beats every package and class typedef.  If Surelog
// does not order it that way, every class typedef in this cell is called a loser
// when golden resolves it.
class zel6;
  int q;
endclass

class zk6;
  int q;
endclass

typedef zel6 unit_t;           // $unit typedef -> group 0, should CLAIM zel6

package pv6;
  class zc6;
    typedef zel6 c_t;          // group 4 -> loses to the $unit typedef
    typedef zk6  k_t;          // only typedef naming zk6 -> claims
  endclass
  typedef zel6 pk6_t;          // group 1: loses to $unit, beats the class
endpackage

class zuser6;                  // a $unit-level class
  typedef zel6 u_t;            // group 4, container "work@zuser6"
  function void f6();
    pv6::zc6::c_t v_c;         // MULTI-SEGMENT through a package root
    zuser6::u_t   v_u;         // a $unit class's own scoped typedef
    v_c = null;
    v_u = null;
  endfunction
endclass

module topv6;
  initial begin
    zuser6 u = new();
    pv6::zc6 c = new();
    u.f6();
  end
endmodule
