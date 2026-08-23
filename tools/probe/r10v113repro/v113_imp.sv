// r10v113 / v113_imp.sv — import shapes: the callee ALSO exists as an
// import-clone in an importing package; calls made from the importer, from a
// second importer, and from a module importing both.
package hsrc;
  function automatic int Pivot(int k); return k + 1; endfunction
  function automatic int quill(int k); return k + 2; endfunction
endpackage

package himp1;
  import hsrc::*;                       // wildcard -> a CLONE of Pivot
  class C1;
    function int above(); return Pivot(91); endfunction
    function int Pivot(int k); return k + 800; endfunction
    function int below(); return Pivot(92); endfunction
  endclass
endpackage

package himp2;
  import hsrc::quill;                   // EXPLICIT single-symbol import
  class C2;
    function int first();  return quill(93); endfunction
    function int quill(int k); return k + 810; endfunction
    function int second(); return quill(94); endfunction
  endclass
endpackage

module tb_imp;
  import himp1::*;
  import himp2::*;
  C1 a; C2 b;
  initial begin a = new(); b = new(); end
endmodule
