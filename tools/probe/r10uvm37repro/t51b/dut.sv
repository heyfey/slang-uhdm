// t51b — pass 37, cell B: the CLASS-METHOD clone, which is where 88% of
// SeqDriver's binding misses live (`DEFPKG adpcm_pkg::uvm_component::
// get_children | ref_obj 'i' -> ref_var:i`).
//
// t51a's free function proved the law but did NOT produce a class-method
// clone.  The trigger is not `extends` and not `-fileunit`: an out-of-body
// class method is a PACKAGE-scope item (§ t48c already recorded this), so it
// is what a wildcard importer clones — an INLINE method body is not in the
// home package's subroutine listing at all.  `extern` + a definition outside
// the class body is the whole difference, and it is how UVM writes nearly
// every method.
//
// Cells, all inside one cloned method so a single clone carries them:
//   * a foreach LOOP VARIABLE over a CLASS PROPERTY array (the corpus shape:
//     `foreach (m_children[i])`) and over a BODY-LOCAL array
//   * that loop variable used as a bit_select INDEX and as a plain rvalue
//   * the bit_select BASE on a class property and on a body local
//   * NEGATIVES: the class property by bare name, `this`, and the implicit
//     function-return variable

package home52;

  class c52;
    int m_kids[4];
    string m_name;
    extern function int count(int lim);
  endclass

  function int c52::count(int lim);
    int loc[4];
    int acc;
    acc = 0;
    // loop var over a CLASS PROPERTY array
    foreach (m_kids[i])
      acc = acc + m_kids[i] + i;
    // loop var over a BODY-LOCAL array
    foreach (loc[k])
      acc = acc + loc[k] + k;
    // NEGATIVES: bare class property, and `this`
    acc = acc + m_kids[0];
    if (this.m_name == "x")
      acc = acc + 1;
    acc = acc + lim;
    count = acc;
  endfunction

endpackage

package imp52;
  import home52::*;
  class d52 extends c52;
    extern function int twice(int lim);
  endclass
  function int d52::twice(int lim);
    return 2 * count(lim);
  endfunction
endpackage

module mm52;
  import imp52::*;
  int q;
  initial q = 0;
endmodule
