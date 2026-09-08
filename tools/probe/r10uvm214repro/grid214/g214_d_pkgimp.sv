// r10uvm214 grid arm D — THE CORPUS TOPOLOGY AND THE IMPORT-CLONE FENCE.
// A second package wildcard-imports the home package, so BOTH of the importer's
// listings carry a `clone_tree` copy of the home's whole subroutine listing —
// the free functions AND the out-of-body class methods.  § pkgParamRefKeepsClone
// Bare178 measured those clone copies BARE in golden (the clone's ref_obj is on
// no late-binding list), and this pass must not disturb that: the import-clone
// cells are the AWAY column of arm D.
//
// The home package's own two listings are in this arm too, so the law's own
// cells and the fence's cells are scored side by side in one database.
package ph214;

  parameter int ha214 = 3;
  parameter hb214 = ha214;
  parameter hc214 = ha214 + 4;

  function automatic int hsink214(int a, int b);
    return a + b;
  endfunction

  function automatic int h_free214();
    return hsink214(ha214, hb214);
  endfunction

  class H214;
    extern function int h_oob214();
    extern function int h_oob_ret214();
  endclass

  function int H214::h_oob214();
    return hsink214(hb214, hc214);
  endfunction

  function int H214::h_oob_ret214();
    return hb214;
  endfunction

endpackage

package pi214;
  import ph214::*;

  parameter int ia214 = 11;
  parameter ib214 = ia214;

  // The importer's OWN out-of-body method, reading the importer's OWN
  // parameters — the law fires here, in pi214's def listing.
  class I214;
    extern function int i_oob214();
  endclass

  function int I214::i_oob214();
    return ia214 + ib214;
  endfunction

endpackage

module topd214;
  ph214::H214 h = new();
  pi214::I214 i = new();
  int x, y;
  initial begin
    x = h.h_oob214();
    y = i.i_oob214();
  end
endmodule
