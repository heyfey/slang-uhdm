// r10uvm181 arm B -- THE DIMENSION GRID.
//
// The same EMPTYTF clone-body shape as arm A, varied on ARITY instead of kind:
// 1-D, 2-D and 3-D loop lists, every named-slot pattern (`[i]`, `[i,j]`,
// `[,j]`, `[i,]`, `[i,j,k]`, `[,,k]`, `[i,,k]`), and a NESTED pair of foreach
// loops whose inner list re-uses the outer name (the shadowing question
// `blockVar9`/`loopVar37`'s innermost-out climb has to answer).
//
// Every subroutine owns NOTHING at its own level; the counter-arm
// `sable181_haslocal` is the identical body with one function-scope `int`, and
// must not move.
package sable181_home;

  int gantry181_1d [4];
  int gantry181_2d [3][3];
  int gantry181_3d [2][2][2];

  function automatic void one181_fn();
    foreach (gantry181_1d[hoist]) begin
      int davit;
      davit = gantry181_1d[hoist] + hoist;
    end
  endfunction

  function automatic void twoboth181_fn();
    foreach (gantry181_2d[jib, boom]) begin
      int davit;
      davit = gantry181_2d[jib][boom] + jib + boom;
    end
  endfunction

  function automatic void twoleft181_fn();
    foreach (gantry181_2d[mast, ]) begin
      int davit;
      davit = mast * 3;
    end
  endfunction

  function automatic void tworight181_fn();
    foreach (gantry181_2d[ , sheave]) begin
      int davit;
      davit = sheave * 5;
    end
  endfunction

  function automatic void threeall181_fn();
    foreach (gantry181_3d[capstan, winch, drum]) begin
      int davit;
      davit = gantry181_3d[capstan][winch][drum] + capstan + winch + drum;
    end
  endfunction

  function automatic void threelast181_fn();
    foreach (gantry181_3d[ , , tackle]) begin
      int davit;
      davit = tackle + 1;
    end
  endfunction

  function automatic void threeskip181_fn();
    foreach (gantry181_3d[bollard, , cleat]) begin
      int davit;
      davit = bollard + cleat;
    end
  endfunction

  // NESTED, with the inner list naming the OUTER variable's neighbour: the
  // innermost-out climb must reach the inner loop's object for `spar` and the
  // outer loop's for `yard`.
  function automatic void nested181_fn();
    foreach (gantry181_2d[yard]) begin
      int davit;
      foreach (gantry181_1d[spar]) begin
        int gaff;
        gaff = gantry181_1d[spar] + yard;
        davit = gaff;
      end
    end
  endfunction

  // NESTED, inner RE-USES the outer name -- the shadowing cell.
  function automatic void shadow181_fn();
    foreach (gantry181_2d[keelson]) begin
      int davit;
      foreach (gantry181_1d[keelson]) begin
        int gaff;
        gaff = gantry181_1d[keelson];
        davit = gaff;
      end
    end
  endfunction

  // CONTROL -- identical body, one function-scope local.
  function automatic void sable181_haslocal();
    int strake;
    foreach (gantry181_1d[thwart]) begin
      int davit;
      davit = gantry181_1d[thwart] + thwart;
      strake = davit;
    end
  endfunction

endpackage

package sable181_imp;
  import sable181_home::*;
  int sable181_anchor;
endpackage

module sable181_top;
  initial sable181_imp::sable181_anchor = 0;
endmodule
