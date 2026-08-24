// r10buvm33repro/g33a2.sv — § foreachScopedArrayWrittenClassVar33, ARM 2:
// the interactions.  The self-select-assign drop (§ foreachArraySelfSelect-
// AssignDropsTs19), the `.`-separated NEGATIVE CONTROLS that must NOT be
// caught, imported and $unit qualifiers, a generic class, an assoc array and
// a package-parameter qualifier.  MEASUREMENT ONLY.

class unitc33;                    // a $unit-scope class
  static int uq33[$];
endclass

package q33;
  class impc33;
    static int iq33[$];
  endclass
  int qv33[$];
  parameter int QP33[3] = '{1,2,3};
endpackage

package r33;
  import q33::*;                  // WILDCARD import of q33

  class holder33;
    static int hq33[$];
    static int ha33[string];
    int inst33[$];
    holder33 peer33;
    typedef holder33 this_type;
    extern function void sel33();
    extern function void neg33();
  endclass

  class gen33 #(type T = int, int W = 1);
    static T gq33[$];
    typedef gen33 #(T, W) this_type;
    function void gm33();
      foreach (this_type::gq33[i])        // G1  generic class, this_type
        gq33.push_back(gq33[i]);
      foreach (gen33::gq33[i])            // G2  generic class, own name
        gq33.push_back(gq33[i]);
    endfunction
  endclass

  // OUT-OF-BODY, package scope: the copy `writePackage` runs
  // `lateTypedefBinding` over — where § foreachArraySelfSelectAssignDropsTs19
  // clears the BARE spelling's typespec.
  function void holder33::sel33();
    begin
      hq33[0] = 7;                        // the SELECT ASSIGN that arms the drop
      foreach (this_type::hq33[i])        // S1  scoped + the drop armed
        hq33.push_back(hq33[i]);
      foreach (hq33[i])                   // S2  BARE control, drop armed
        hq33.push_back(hq33[i]);
      foreach (this_type::ha33[k])        // S3  scoped ASSOC array
        hq33.push_back(1);
      foreach (unitc33::uq33[i])          // S4  a $unit class qualifier
        hq33.push_back(unitc33::uq33[i]);
      foreach (impc33::iq33[i])           // S5  a WILDCARD-IMPORTED class
        hq33.push_back(impc33::iq33[i]);
      foreach (q33::impc33::iq33[i])      // S6  package :: class :: property
        hq33.push_back(q33::impc33::iq33[i]);
      foreach (q33::qv33[i])              // S7  a package VARIABLE
        hq33.push_back(q33::qv33[i]);
      foreach (q33::QP33[i])              // S8  a package PARAMETER array
        hq33.push_back(q33::QP33[i]);
    end
  endfunction

  // The NEGATIVE CONTROLS: a `.` separator is NOT a `::` scope and must keep
  // its existing shape (§ classPropIterThisRefVar21 / the hier_path arm).
  function void holder33::neg33();
    foreach (this.inst33[i])              // N1  `this.` — typespec-LESS ref_var
      hq33.push_back(1);
    foreach (peer33.inst33[i])            // N2  dotted — a hier_path
      hq33.push_back(1);
    foreach (inst33[i])                   // N3  bare
      hq33.push_back(1);
  endfunction

endpackage

module top33a2;
  import r33::*;
  holder33 h1_33, h2_33;
  gen33 #(int, 1) g1_33;
  gen33 #(byte, 2) g2_33;
  int tq33[$];
  initial begin
    foreach (r33::holder33::hq33[i])      // T1  from a MODULE home
      tq33.push_back(1);
    foreach (unitc33::uq33[i])            // T2  $unit class from a module
      tq33.push_back(1);
    foreach (tq33[i])                     // T3  bare control
      tq33.push_back(1);
  end
endmodule
