// r10uvm211 arm G — THE PACKED LINK.  A PACKED array of a PACKED struct of a
// package scalar typedef, walked by `foreach`, so the split walks
// `packed_array_typespec`'s `Elem_typespec` rather than `array_typespec`'s.
package p211a_g;
  typedef bit [15:0] bt211g;
  typedef struct packed { bt211g g_min211; bt211g g_max211; } sg211;

  function automatic int fg211();
    sg211 [3:0] lg211;
    int t211g;
    foreach (lg211[i211g]) t211g = t211g + int'(lg211[i211g].g_min211);
    return t211g;
  endfunction
endpackage

package p211b_g;
  import p211a_g::*;
  function automatic int gb211g();
    return fg211();
  endfunction
endpackage

module g211_g_packed;
  import p211b_g::*;
  int r211g;
  initial r211g = gb211g();
endmodule
