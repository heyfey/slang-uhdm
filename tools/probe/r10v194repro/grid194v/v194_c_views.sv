// r10v194 arm C — THE VIEW AND SHADOW AXES.
//
//   (1) an IN-BODY class method with the select as a DIRECT statement of its
//       block — the `cd != nullptr` half of § classRetNameDefViewNoBind37's
//       predicate, which the r10uvm194 exemption ALSO reaches.  r10uvm194's
//       arm A reports golden NULL / patched NULL for this cell; this arm
//       re-measures it against its own real golden.
//   (2) an ORPHAN package that nothing imports (its class_defn is DEF-only in
//       a package that is not a top package).
//   (3) a class inside a MODULE — never in defCds or topCds, so § 37 never
//       touches it; a select there must be identical on both binaries.
//   (4) a LOCAL in a nested named block SHADOWING the enclosing function's own
//       name, with a select on the SHADOW.  Surelog's `uhdmbegin` arm matches
//       on NAME, ours on the slang Symbol; the cell says which.
//   (5) THREE INSTANCES of a wrapper module that calls the same methods, so
//       instance multiplicity is scored rather than assumed.
package vc194_src;
  class VC194;
    // (1) IN BODY, direct select.
    function string c_in();
      int i; i=0;
      c_in = {c_in," "};
      c_in[i] = 8'h41;
    endfunction
    extern function string c_out();
    extern function string c_shadow();
  endclass

  function string VC194::c_out();
    int i; i=0;
    c_out = {c_out," "};
    c_out[i] = 8'h42;
  endfunction

  // (4) the SHADOW: a named block declares a variable with the function's own
  //     name and bit-selects IT.
  function string VC194::c_shadow();
    int i; i=0;
    c_shadow = {c_shadow," "};
    begin : shb
      byte c_shadow;
      c_shadow = 8'h00;
      c_shadow[0] = 1'b1;
    end
  endfunction
endpackage

// (2) an ORPHAN package: imported by nobody.
package vc194_orphan;
  class VCO194;
    extern function string o_out();
  endclass
  function string VCO194::o_out();
    int i; i=0;
    o_out = {o_out," "};
    o_out[i] = 8'h43;
  endfunction
endpackage

module vc194_wrap;
  import vc194_src::*;
  // (3) a class declared INSIDE a module.
  class VCM194;
    function string m_in();
      int i; i=0;
      m_in = {m_in," "};
      m_in[i] = 8'h44;
    endfunction
  endclass

  VC194  h;
  VCM194 g;
  string s1, s2, s3, s4;
  initial begin
    h = new();
    g = new();
    s1 = h.c_in();
    s2 = h.c_out();
    s3 = h.c_shadow();
    s4 = g.m_in();
  end
endmodule

// (5) THREE instances.
module vc194_top;
  vc194_wrap u1();
  vc194_wrap u2();
  vc194_wrap u3();
endmodule
