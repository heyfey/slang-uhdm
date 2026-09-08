// r10uvm211 arm E — THE EXPLICIT (NAMED) IMPORT.  `CompileHelper::
// importPackage`'s `object_name` filter clones a named import too, and golden
// bares that clone's array-of-struct members exactly as it bares a wildcard
// clone's — but `pkgImportCloneTfs16` is WILDCARD-ONLY by § 194's committed
// fence, so this arm must be BYTE-IDENTICAL on both binaries and the residue
// stands ON PURPOSE.
package p211a_e;
  typedef bit [63:0] bt211e;
  typedef struct { bt211e e_addr211; bt211e e_data211; } se211;

  function automatic int fe211();
    se211 le211[$];
    return le211.size();
  endfunction
endpackage

package p211b_e;
  import p211a_e::fe211;
  import p211a_e::se211;
  function automatic int gb211e();
    return fe211();
  endfunction
endpackage

module g211_e_named;
  import p211b_e::*;
  int r211e;
  initial r211e = gb211e();
endmodule
