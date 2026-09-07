// r10v189 arm W — a KEYWORD-indexed assoc local only.  The promoted render
// already exists on BOTH binaries here, so whatever the clone listing's
// typespec vpiInstance does is visible WITHOUT this law.
package HomeW189v;
  class HoldW189v;
    extern function void oobW189v();
  endclass
  function void HoldW189v::oobW189v();
    bit kwW189v[string];
    kwW189v["a"] = 1'b1;
  endfunction
  function void freeW189v();
    bit kwfW189v[string];
    kwfW189v["b"] = 1'b1;
  endfunction
endpackage
package UserW189v;
  import HomeW189v::*;
  function void useW189v();
    HoldW189v hW189v;
    hW189v = new();
    hW189v.oobW189v();
    freeW189v();
  endfunction
endpackage
module topW189v;
  import UserW189v::*;
  initial useW189v();
endmodule
