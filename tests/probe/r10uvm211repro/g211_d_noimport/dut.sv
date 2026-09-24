// r10uvm211 arm D — THE HOME-ONLY CONTROL.  The same array-of-struct
// declarations with NO import anywhere, so `pkgImportCloneTfs16` is EMPTY and
// the law's gate never opens.  BOTH binaries must produce a BYTE-IDENTICAL
// database.
package p211a_d;
  typedef bit [63:0] bt211d;
  typedef struct { bt211d d_addr211; bt211d d_data211; } sd211;

  function automatic int fhome211d();
    sd211 lhome211d[$];
    return lhome211d.size();
  endfunction
endpackage

module g211_d_noimport;
  int r211d;
  initial r211d = p211a_d::fhome211d();
endmodule
