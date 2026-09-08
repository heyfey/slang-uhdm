// r10uvm208 arm B — TWO CLONES OF THE SAME BODY.  Two importing packages
// wildcard-import the same declaring package, so `CompileHelper::importPackage`
// clone_trees the same subroutine TWICE and a memoised element chain is reached
// from THREE worlds — the home and both clones.
//
// It decides two things at once:
//   * a chain shared by TWO CLONES ONLY carries owner mask 1 and is § 205's
//     re-point, not this law's — the split must NOT fire there (`fnoc208`,
//     which the home never walks by `foreach`);
//   * a chain the HOME also reaches carries mask 3 and IS this law's — and
//     BOTH clone declarations must get their OWN fresh chain while the single
//     home cell keeps its QUALIFIED target (`f2_208`).
package p208a_2;
  typedef bit [7:0] bt208;

  // the crossing case: the home walks it with `foreach`
  function automatic int f2_208(input int n208);
    bt208 sh208[];
    int   a208 = 0;
    foreach (sh208[i208])
      a208 += int'(sh208[i208]);
    return a208 + n208;
  endfunction

  // the NON-crossing case: no home reference variable is ever minted for it,
  // so both clones share a chain the home does not hold
  function automatic int fnoc208(input int n208);
    bt208 nc208[];
    return nc208.size() + n208;
  endfunction
endpackage

package p208b_2;
  import p208a_2::*;
  function automatic int g2b_208();
    return f2_208(1) + fnoc208(1);
  endfunction
endpackage

package p208c_2;
  import p208a_2::*;
  function automatic int g2c_208();
    return f2_208(2) + fnoc208(2);
  endfunction
endpackage

module g208_b_twoclone;
  import p208b_2::*;
  import p208c_2::*;
  int r208;
  initial r208 = g2b_208() + g2c_208();
endmodule
