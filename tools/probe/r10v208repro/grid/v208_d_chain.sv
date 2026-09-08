// r10v208 arm D — THE TRANSITIVE IMPORT.  p208a is wildcard-imported by p208b,
// and p208b is wildcard-imported by p208c, so Surelog's `importPackage`
// clone_trees a body that is ITSELF already a clone.  § 208 must give each
// clone declaration its own chain and must never move the home's cell.
package p208a_vd;
  typedef bit [7:0] bt208vd;
  function automatic int fh208vd(input int n208);
    bt208vd sh208[];
    int a208 = 0;
    foreach (sh208[i208])
      a208 += int'(sh208[i208]);
    return a208 + n208;
  endfunction
endpackage

package p208b_vd;
  import p208a_vd::*;
  function automatic int gb208vd();
    return fh208vd(1);
  endfunction
endpackage

package p208c_vd;
  import p208b_vd::*;
  function automatic int gc208vd();
    return gb208vd() + 1;
  endfunction
endpackage

module v208_d_chain;
  import p208c_vd::*;
  int r208;
  initial r208 = gc208vd();
endmodule
