// r10uvm211 arm H — THE FOREIGN STRUCT.  The array's element struct comes from
// a THIRD package the IMPORTER never imports, walked by `foreach` so the array
// is shared exactly as the corpus's is.  The law is thereby tested on whether
// it is about the CLONE BODY (r10uvm207 arm H's finding) rather than about
// which package declares the element's type.
package p211z_h;
  typedef bit [63:0] bt211h;
  typedef struct { bt211h h_addr211; bt211h h_data211; } sh211;
endpackage

package p211a_h;
  import p211z_h::*;
  function automatic int fh211();
    sh211 lh211[$];
    int t211h;
    foreach (lh211[i211h]) t211h = t211h + int'(lh211[i211h].h_addr211);
    return t211h;
  endfunction
endpackage

package p211b_h;
  import p211a_h::*;
  function automatic int gb211h();
    return fh211();
  endfunction
endpackage

module g211_h_foreign;
  import p211b_h::*;
  int r211h;
  initial r211h = gb211h();
endmodule
