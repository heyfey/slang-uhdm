// r10uvm65 VERIFIER arm v2_views.sv - THE VIEW-MULTIPLICITY AXIS.
//
// sec 65 fires on ONE shared body path in emitTaskFuncs, so every VIEW a
// subroutine is emitted in gets its own copy of the block.  The implementer's
// arms open exactly two of those views (def+elab of a plain module, b2 d17/d18)
// and lean on the CORPUS - SeqDriver's adpcm_pkg clone - for the third.  The
// views a source arm can reach and b1/b2/b3 never do are:
//
//   m01/m02  a WILDCARD-IMPORT package clone (the SeqDriver shape) reproduced in
//            an arm rather than inferred from a whole-UVM dump
//   p01/p02  a PARAMETERIZED class with TWO specializations (two class_defns,
//            hence two emissions of the same source method)
//   g01      a module instantiated TWICE (def view + two elab views)
//   g02      a subroutine inside a GENERATE FOR body (two generate blocks)
//   n01      a NESTED class
//   i01      an INTERFACE CLASS pure-virtual prototype (must not fire: no body
//            syntax at all)
//   d01      a DPI IMPORT (no body syntax, different syntax NODE KIND)
//   x01      a CHECKER-scope function
//
// Every cell is empty-bodied with an end label, i.e. the exact sec 65 shape; the
// question this arm answers is whether the count of blocks per source site
// matches golden's count in every view, not merely whether one appears.

package v2src;
  class v2c;
    function void m01_f_lbl();
    endfunction : m01_f_lbl                                  // m01
    task m02_t_port(int a);
    endtask : m02_t_port                                     // m02
  endclass
endpackage

// the CLONE view: a package that wildcard-imports the one above
package v2clone;
  import v2src::*;
  class v2use;
    function void use_it();
      v2c h;
      h = new();
    endfunction : use_it
  endclass
endpackage

// ---- p01/p02: a PARAMETERIZED class, specialized twice
package v2parm;
  class v2pc #(int W = 1);
    function void p01_f_lbl();
    endfunction : p01_f_lbl                                  // p01
    task p02_t_port(int a);
    endtask : p02_t_port                                     // p02
  endclass
  class v2pu;
    v2pc #(1) h1;
    v2pc #(2) h2;
  endclass
endpackage

// ---- n01: a NESTED class
package v2nest;
  class outerc;
    class innerc;
      function void n01_f_lbl();
      endfunction : n01_f_lbl                                // n01
    endclass
  endclass
endpackage

// ---- i01: an INTERFACE CLASS prototype (no body syntax)
package v2iface;
  interface class v2ic;
    pure virtual function void i01_f_pure();
  endclass
endpackage

// ---- g01: a module instantiated twice; g02: generate-for
module v2sub;
  function void g01_f_lbl();
  endfunction : g01_f_lbl                                    // g01
endmodule

module v2gen;
  v2sub u1();
  v2sub u2();
  for (genvar gi = 0; gi < 2; gi++) begin : gblk
    function void g02_f_lbl();
    endfunction : g02_f_lbl                                  // g02
  end
endmodule

// ---- d01: a DPI import (no body syntax at all)
module v2dpi;
  import "DPI-C" function void d01_dpi(int a);
endmodule

// ---- x01: a checker-scope function
checker v2chk;
  function void x01_f_lbl();
  endfunction : x01_f_lbl                                    // x01
endchecker

module v2top;
  v2gen g();
endmodule
