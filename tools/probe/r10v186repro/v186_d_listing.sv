// r10v186 (VERIFIER) ARM D — THE LISTING AXIS, re-asked independently.
//
// The whole law is a LISTING test (`pkgImportCloneEmit`), so the arm that can
// convict it is the one that puts ONE declaration face into every listing a
// database can hold and reads golden's answer in each.  r10uvm186's arm B does
// this for a free function; this one adds the faces its arm B does not carry:
// an EXPLICIT single-item import (`import P::fn;`) AND an explicit type
// import, a package that is wildcard-imported by TWO different packages, a
// package wildcard-imported DIRECTLY BY A MODULE (no clone listing at all),
// a `$unit`-scope subroutine, a MODULE-homed subroutine, and a class method
// reached only through an explicit import.
//
// Names, numbers and orders deliberately unlike the corpus' and unlike
// r10uvm186's own arms.

// $unit scope — no package home at all.
function automatic int unitfn186v(input int u_a);
  int udyn186v[];
  int uloc186v;
  uloc186v = u_a + 1;
  udyn186v = new[uloc186v];             // L1  a $unit subroutine
  return udyn186v.size();
endfunction

package Ogee186v;
  int shelf186v = 21;
  function automatic int reveal186v(input int in_a);
    int   dyn186v[];
    int   loc186v;
    int   src186v[];
    loc186v = in_a + 2;
    src186v = new[2];
    dyn186v = new[loc186v];             // L2  the body local
    dyn186v = new[in_a];                // L3  the formal
    dyn186v = new[loc186v](src186v);    // L4  the copy source
    dyn186v = new[shelf186v];           // L5  a PACKAGE variable (the FENCE)
    return dyn186v.size();
  endfunction
  class Torus186v;
    int m_stub;
    int m_pack[];
    extern function int bead186v(input int in_b);
  endclass
  function int Torus186v::bead186v(input int in_b);
    int dyn186v[];
    int bloc186v;
    bloc186v = in_b + 3;
    dyn186v = new[bloc186v];            // L6  out-of-body method body local
    m_pack  = new[m_stub];              // L7  a CLASS PROPERTY (the FENCE)
    return dyn186v.size();
  endfunction
endpackage

// WILDCARD import number 1.
package Fillet186v;
  import Ogee186v::*;
  function automatic int use_fillet186v();
    Torus186v t186v;
    t186v = new();
    return reveal186v(1) + t186v.bead186v(2);
  endfunction
endpackage

// WILDCARD import number 2 — the same home, a second clone listing.
package Listel186v;
  import Ogee186v::*;
  function automatic int use_listel186v();
    return reveal186v(3);
  endfunction
endpackage

// EXPLICIT single-item import — NOT the wildcard flag this law gates on.
package Echinus186v;
  import Ogee186v::reveal186v;
  import Ogee186v::Torus186v;
  function automatic int use_echinus186v();
    Torus186v t2186v;
    t2186v = new();
    return reveal186v(4) + t2186v.bead186v(5);
  endfunction
endpackage

// A MODULE home — the § newArrayArgNoBind16 symbol half's own counter-witness.
module cyma186v(output int out_d);
  function automatic int modfn186v(input int m_a);
    int mdyn186v[];
    int mloc186v;
    mloc186v = m_a + 4;
    mdyn186v = new[mloc186v];           // L8  a MODULE-homed subroutine
    return mdyn186v.size();
  endfunction
  assign out_d = modfn186v(6);
endmodule

module top186vd;
  import Fillet186v::*;                 // a package that imports Ogee186v::*
  import Ogee186v::*;                   // and Ogee186v DIRECTLY into a module
  int tot186v;
  int mo186v;
  cyma186v cy186v(.out_d(mo186v));
  initial begin
    tot186v = use_fillet186v() + Listel186v::use_listel186v() +
              Echinus186v::use_echinus186v() + unitfn186v(7) +
              reveal186v(8) + mo186v;
    $display("%0d", tot186v);
  end
endmodule
