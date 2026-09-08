// r10v208 arm B — THE INDEX_TYPESPEC FACE.  § 208's `splitTs208` copies and may
// SPLIT an array_typespec's Index_typespec as well as its Elem_typespec.  An
// associative array indexed BY the package typedef is the only shape that puts
// the typedef on that link.  Home walks it with foreach; a wildcard importer's
// clone body declares the same shape.
package p208a_vb;
  typedef bit [7:0] bt208vb;
  function automatic int fh208vb(input int n208);
    bt208vb aa208[bt208vb];
    int a208 = 0;
    foreach (aa208[i208])
      a208 += int'(aa208[i208]);
    return a208 + n208;
  endfunction
endpackage

package p208b_vb;
  import p208a_vb::*;
  function automatic int gb208vb();
    return fh208vb(1);
  endfunction
endpackage

module v208_b_assoc;
  import p208b_vb::*;
  int r208;
  initial r208 = gb208vb();
endmodule
