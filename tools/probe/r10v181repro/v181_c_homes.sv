// r10v181 arm C -- HOMES, INSTANCES AND ARITY, varied against each other so
// that an arm which agrees agrees for a reason.
//
//   * ONE home package imported by TWO different clone packages -- the law
//     must produce the same answer in both clones and must leave the HOME
//     listing alone (law 37's home-vs-clone split is the boundary that must
//     not move).
//   * a MODULE that wildcard-imports the home (a module is not a package
//     clone; `pkgImportCloneEmit` is false there, so nothing may move).
//   * an EXPLICIT (non-wildcard) import clone -- `import home::name;` is not
//     the wildcard shape the law is named for.
//   * arity: 1-D, 2-D and 3-D foreach lists with SKIPPED slots
//     (`[,brail]`, `[strake,,keelson]`) inside EMPTYTF bodies.
//   * a NESTED foreach with DISTINCT names (the non-shadowing nest, which the
//     implementer's arm B only covered in its shadowing form).
//   * THREE instances of the top module, to prove the answer is not
//     instance-count dependent.
package caravel_home;

  int caravel_1d [4];
  int caravel_2d [3][2];
  int caravel_3d [2][2][2];
  int caravel_sink;

  // EMPTYTF, 1-D
  function automatic int mizzen181_one();
    foreach (caravel_1d[strake])
      mizzen181_one = caravel_1d[strake] + strake;
  endfunction

  // EMPTYTF, 2-D, both slots named
  function automatic int mizzen181_two();
    foreach (caravel_2d[strake, brail])
      mizzen181_two = caravel_2d[strake][brail] + strake + brail;
  endfunction

  // EMPTYTF, 2-D, FIRST slot skipped
  function automatic int mizzen181_skipfirst();
    foreach (caravel_2d[, brail])
      mizzen181_skipfirst = brail;
  endfunction

  // EMPTYTF, 3-D, MIDDLE slot skipped
  function automatic int mizzen181_skipmid();
    foreach (caravel_3d[strake, , keelson])
      mizzen181_skipmid = strake + keelson;
  endfunction

  // EMPTYTF, NESTED with DISTINCT names
  function automatic int mizzen181_nest();
    foreach (caravel_1d[strake])
      foreach (caravel_2d[futtock, brail]) begin
        int gunwale;
        gunwale = caravel_1d[strake] + caravel_2d[futtock][brail];
        mizzen181_nest = gunwale;
      end
  endfunction

  // EMPTYTF task on the same 3-D array
  task automatic mizzen181_task();
    foreach (caravel_3d[strake, brail, keelson])
      caravel_sink = caravel_3d[strake][brail][keelson];
  endtask

  // HASLOCALS control for the 2-D case
  function automatic int mizzen181_ctrl();
    int transom;
    foreach (caravel_2d[strake, brail]) begin
      transom = caravel_2d[strake][brail] + strake + brail;
      mizzen181_ctrl = transom;
    end
  endfunction

endpackage

// TWO wildcard clones of the same home.
package caravel_impone;
  import caravel_home::*;
  int caravel_anchorone;
endpackage

package caravel_imptwo;
  import caravel_home::*;
  int caravel_anchortwo;
endpackage

// An EXPLICIT-import package: not the wildcard shape.
package caravel_impexp;
  import caravel_home::mizzen181_one;
  int caravel_anchorexp;
endpackage

// A MODULE that wildcard-imports: never a package clone.
module caravel_mod;
  import caravel_home::*;
  int caravel_modarr [3];
  int caravel_modsink;
  function automatic int mizzen181_modfn();
    foreach (caravel_modarr[strake])
      mizzen181_modfn = caravel_modarr[strake] + strake;
  endfunction
  initial caravel_modsink = mizzen181_modfn();
endmodule

module caravel_top;
  caravel_mod hullone();
  caravel_mod hulltwo();
  caravel_mod hullthree();
  initial begin
    caravel_impone::caravel_anchorone = 0;
    caravel_imptwo::caravel_anchortwo = 0;
    caravel_impexp::caravel_anchorexp = 0;
  end
endmodule
