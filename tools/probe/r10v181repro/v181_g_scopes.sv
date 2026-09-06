// r10v181 arm G -- THE CLIMB's own axes, which only open for an EMPTYTF clone
// body once `pkgCloneBodyLocals9` registers it.
//
// `bind9`'s innermost-out climb consults, at each enclosing level, a
// `foreach_stmt`'s `VpiLoopVars` and a `begin` / `named_begin` / `fork_stmt` /
// `named_fork`'s `Variables()`.  In an EMPTYTF body none of that ran before
// this pass, so every one of these is a first-time surface:
//
//   * SHADOWING: two SIBLING blocks each declaring the same name, and a
//     NESTED block redeclaring an enclosing block's name -- the reference must
//     reach ITS OWN, and a climb that stopped at the first hit of the name
//     anywhere would cross-bind them.
//   * the foreach's ARRAY being a BLOCK-LOCAL of an enclosing block (the
//     `ref_var` that names the array, not the loop variable).
//   * a NAMED begin, and a FORK body, as the enclosing scope.
//   * a `for` loop variable and a `repeat`/`while` body inside the clone.
//   * a reference in a SIBLING block to a name declared only in the OTHER
//     block -- there is no such declaration in scope, so it must stay bare in
//     both (a climb that walked the whole subroutine instead of the parent
//     chain would bind it).
package palisade_home;

  int palisade_outer [3];
  int palisade_sink;

  // EMPTYTF: no formals, no function-scope Variables.
  function automatic void redoubt181_empty();
    foreach (palisade_outer[banquette]) begin
      int scarp;
      int glacis [4];
      scarp = banquette;
      begin : ravelin
        int scarp;                       // SHADOWS the enclosing `scarp`
        scarp = banquette + 1;
        palisade_sink = scarp;
      end
      begin : demilune
        int counterscarp;                // a SIBLING's name
        counterscarp = scarp + 2;        // reaches the OUTER `scarp`
        palisade_sink = counterscarp;
      end
      foreach (glacis[embrasure])        // array is a BLOCK-LOCAL
        palisade_sink = glacis[embrasure] + banquette;
      for (int enceinte = 0; enceinte < 3; enceinte++)
        palisade_sink = palisade_sink + enceinte;
      begin : hornwork
        int scarp;                       // a THIRD `scarp`, sibling of ravelin
        scarp = 7;
        palisade_sink = scarp;
      end
    end
  endfunction

  // EMPTYTF with a FORK body around the same shapes.
  task automatic redoubt181_fork();
    foreach (palisade_outer[banquette])
      fork
        begin
          int scarp;
          scarp = banquette;
          palisade_sink = scarp;
        end
        begin
          int scarp;
          scarp = banquette + 1;
          palisade_sink = scarp;
        end
      join
  endtask

  // HASLOCALS twin of the first, identical body.
  function automatic void redoubt181_haslocal();
    int caponier;
    foreach (palisade_outer[banquette]) begin
      int scarp;
      int glacis [4];
      scarp = banquette;
      begin : ravelin
        int scarp;
        scarp = banquette + 1;
        palisade_sink = scarp;
      end
      begin : demilune
        int counterscarp;
        counterscarp = scarp + 2;
        palisade_sink = counterscarp;
      end
      foreach (glacis[embrasure])
        palisade_sink = glacis[embrasure] + banquette;
      for (int enceinte = 0; enceinte < 3; enceinte++)
        palisade_sink = palisade_sink + enceinte;
      begin : hornwork
        int scarp;
        scarp = 7;
        palisade_sink = scarp;
      end
      caponier = palisade_sink;
    end
  endfunction

endpackage

package palisade_imp;
  import palisade_home::*;
  int palisade_anchor;
endpackage

module palisade_top;
  initial palisade_imp::palisade_anchor = 0;
endmodule
