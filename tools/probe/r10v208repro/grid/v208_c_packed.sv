// r10v208 arm C — THE PACKED_ARRAY_TYPESPEC FACE.  § 208 has a second mint
// branch for `packed_array_typespec` that no committed arm exercises by name.
// A packed array OF a package scalar typedef, declared in a body the home also
// walks, wildcard-imported.
package p208a_vc;
  typedef bit [7:0] bt208vc;
  function automatic int fh208vc(input int n208);
    bt208vc pk208 [3:0];
    bt208vc dy208 [];
    int a208 = 0;
    foreach (pk208[i208])
      a208 += int'(pk208[i208]);
    foreach (dy208[j208])
      a208 += int'(dy208[j208]);
    return a208 + n208;
  endfunction
endpackage

package p208b_vc;
  import p208a_vc::*;
  function automatic int gb208vc();
    return fh208vc(1);
  endfunction
endpackage

module v208_c_packed;
  import p208b_vc::*;
  int r208;
  initial r208 = gb208vc();
endmodule
