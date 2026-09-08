// r10v208 arm A — THE OUTER/INNER ALIASING PROBE.
// § 208's exclusivity guard `outer208` is built ONLY from `variables` and
// `io_decl` declarations.  If a clone declaration's OWN ref_typespec were ALSO
// the Elem_typespec ref of a HOME array, the mask would still read 1 and the
// split would re-point an object the home reaches.  Shape: the home declares a
// 2-D dynamic array of the package typedef (its element type IS `bt[]`) and
// walks it with foreach; the clone-reached body declares a plain `bt[]`.
package p208a_va;
  typedef bit [7:0] bt208va;
  function automatic int fh208va(input int n208);
    bt208va two208[][];
    int a208 = 0;
    foreach (two208[i208])
      a208 += two208[i208].size();
    return a208 + n208;
  endfunction
  function automatic int fc208va(input int n208);
    bt208va one208[];
    int b208 = 0;
    foreach (one208[j208])
      b208 += int'(one208[j208]);
    return b208 + n208;
  endfunction
endpackage

package p208b_va;
  import p208a_va::*;
  function automatic int gb208va();
    return fh208va(1) + fc208va(2);
  endfunction
endpackage

module v208_a_alias;
  import p208b_va::*;
  int r208;
  initial r208 = gb208va();
endmodule
