// r10v205 arm G — THE INDEX LINK.  § cloneArrayElemBareTdAlias205's walk
// descends `Index_typespec` as well as `Elem_typespec`, and the pass measured
// ZERO differing `.index` cells on the corpus, so the index branch ships
// UNTESTED.  An associative array whose INDEX type is a package scalar typedef,
// declared inside a wildcard-import clone body, is the shape that exercises it.
package p205a_g;
  typedef bit [7:0]  bt205;
  typedef int        it205;
  function automatic int fg205(input bt205 gio205[]);
    bt205 amap205 [it205];     // index typespec = it205, elem typespec = bt205
    it205 bmap205 [bt205];     // the mirror
    bt205 cmap205 [string];    // a NON-typedef index
    int s205 = 0;
    amap205[0] = 8'h1; bmap205[8'h2] = 3; cmap205["k"] = 8'h4;
    s205 = amap205.size() + bmap205.size() + cmap205.size();
    return s205 + gio205.size();
  endfunction
endpackage

package p205b_g;
  import p205a_g::*;
  function automatic int gg205();
    bt205 z205[];
    return fg205(z205);
  endfunction
endpackage

module v205_g_index;
  import p205b_g::*;
  int r205;
  initial r205 = gg205();
endmodule
