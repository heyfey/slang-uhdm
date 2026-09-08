// r10v208 arm J — THE MODULE IMPORTER CONTROL.  `pkgImportCloneTfs16` is
// populated only for a PACKAGE's wildcard import of another package, because
// only that path makes Surelog clone_tree a subroutine body.  A MODULE that
// wildcard-imports the same package must produce a byte-identical database on
// both binaries.
package p208a_vj;
  typedef bit [7:0] bt208vj;
  function automatic int fh208vj(input int n208);
    bt208vj hm208[];
    int a208 = 0;
    foreach (hm208[i208]) a208 += int'(hm208[i208]);
    return a208 + n208;
  endfunction
endpackage

module v208_j_modimp;
  import p208a_vj::*;
  bt208vj loc208[];
  int r208;
  initial r208 = fh208vj(1) + loc208.size();
endmodule
