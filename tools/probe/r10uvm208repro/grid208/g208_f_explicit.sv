// r10uvm208 arm F — THE EXPLICIT-IMPORT CONTROL, § 194's committed fence.
// `CompileHelper::importPackage`'s `object_name` filter clones a NAMED import
// too, and golden bares that clone's chain exactly as it bares a wildcard
// clone's — but `pkgImportCloneTfs16` is WILDCARD-ONLY by § 194's measured
// fence, so this arm must be BYTE-IDENTICAL on both binaries in both views.
// That is r10uvm205's R3, left standing on purpose; this arm re-measures it
// under the split so a widened gate would be caught here.
package p208a_x;
  typedef bit [7:0] bt208;
  function automatic int fx208(input int n208);
    bt208 xs208[];
    begin
      bt208 xs2_208[];
      return xs208.size() + xs2_208.size() + n208;
    end
  endfunction
endpackage

package p208b_x;
  import p208a_x::fx208;
  function automatic int gx208();
    return fx208(1);
  endfunction
endpackage

module g208_f_explicit;
  import p208b_x::*;
  int r208;
  initial r208 = gx208();
endmodule
