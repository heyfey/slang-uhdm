// t48c — pass 36, cell C: an OUT-OF-BODY class method whose formal is typed by
// the class's OWN class-scope typedef, cloned into a wildcard importer.
//
// SeqDriver's last 2 rows:
//   DEFPKG  adpcm_pkg::::uvm_sequence_library::m_check io[1] 'lib'
//   ELABPKG adpcm_pkg::::uvm_sequence_library::m_check io[1] 'lib'
//     golden unsupported_typespec 'this_type' @uvm_pkg
//     ours   class_typespec 'adpcm_pkg::this_type' @adpcm_pkg
//
// The row exists at all because UVM declares the method `extern static` and
// DEFINES it out of body at PACKAGE scope — so a wildcard importer clones it
// as a package subroutine, and in that copy `this_type` has no class scope to
// resolve against.  § dpiImportCopyFormalUnsupported33 is the same degradation
// one predicate over (there it is DPI-ness that triggers it).
//
// `k50_t` is the CONTROL: an ordinary package typedef used as the OTHER formal
// of the same out-of-body method, which must NOT degrade.

package home50;
  typedef int k50_t;
  class c50;
    typedef c50 this_type;
    extern static function bit m50(k50_t key, this_type lib);
    // an IN-BODY method with the same formal, to separate out-of-body from
    // in-body in the same golden
    function bit i50(this_type lib);
      return 1'b1;
    endfunction
  endclass
  function bit c50::m50(k50_t key, this_type lib);
    return 1'b0;
  endfunction
endpackage

package aa50;
  import home50::*;
  class u50;
    function bit q50(k50_t key);
      return 1'b1;
    endfunction
  endclass
endpackage

module mm50;
  import home50::*;
  k50_t s50;
  initial s50 = 0;
endmodule
