// r10uvm181 arm A -- THE ARRAY-KIND GRID for a clone body that owns NOTHING.
//
// Every subroutine here is the EMPTYTF shape the law is about: no formals, no
// return variable, no function-scope declaration at all -- every declaration
// lives inside the foreach's own `begin`.  One subroutine per ARRAY KIND, each
// iterating a PACKAGE-level array so the loop variable is the only name the
// clone has to resolve, and each reading the loop variable in three positions
// (a bit_select index, a plain rvalue, and a nested expression) so a rule that
// only reaches one position shows up as a split cell.
//
// `wren181_home` is the home; `wren181_imp` wildcard-imports it and therefore
// CLONES every one of these free functions (an out-of-body class method is a
// package item too -- arm C).  Names are deliberately unlike the corpus's and
// unlike each other, so an arm that agrees agrees for a reason.
package wren181_home;

  typedef struct packed { logic [3:0] gable; logic [3:0] mullion; } lintel181_t;

  int          quarry181_fixed [6];
  int          quarry181_queue [$];
  int          quarry181_dyn   [];
  int          quarry181_assoc [string];
  logic [11:0] quarry181_packd;
  lintel181_t  quarry181_strq  [$];
  string       quarry181_strs  [4];

  // ---- fixed unpacked -------------------------------------------------
  function automatic void fixed181_fn();
    foreach (quarry181_fixed[trellis]) begin
      int corbel;
      corbel = quarry181_fixed[trellis];
      corbel = corbel + trellis;
      if (corbel > (trellis * 2)) corbel = 0;
    end
  endfunction

  // ---- queue ----------------------------------------------------------
  function automatic void queue181_fn();
    foreach (quarry181_queue[louver]) begin
      int corbel;
      corbel = quarry181_queue[louver];
      corbel = corbel + louver;
      if (corbel > (louver * 2)) corbel = 0;
    end
  endfunction

  // ---- dynamic --------------------------------------------------------
  function automatic void dyn181_fn();
    foreach (quarry181_dyn[soffit]) begin
      int corbel;
      corbel = quarry181_dyn[soffit];
      corbel = corbel + soffit;
      if (corbel > (soffit * 2)) corbel = 0;
    end
  endfunction

  // ---- associative [string] -------------------------------------------
  function automatic void assoc181_fn();
    foreach (quarry181_assoc[plinth]) begin
      int corbel;
      corbel = quarry181_assoc[plinth];
      if (plinth == "keystone") corbel = 0;
    end
  endfunction

  // ---- packed vector --------------------------------------------------
  function automatic void packd181_fn();
    foreach (quarry181_packd[fascia]) begin
      logic corbel;
      corbel = quarry181_packd[fascia];
      if (corbel && (fascia > 3)) corbel = 1'b0;
    end
  endfunction

  // ---- queue of packed struct (the aggregate element) ------------------
  function automatic void strq181_fn();
    foreach (quarry181_strq[muntin]) begin
      lintel181_t corbel;
      corbel = quarry181_strq[muntin];
      corbel.gable = corbel.gable ^ 4'(muntin);
    end
  endfunction

  // ---- fixed array of string ------------------------------------------
  function automatic void strs181_fn();
    foreach (quarry181_strs[reveal]) begin
      string corbel;
      corbel = quarry181_strs[reveal];
      corbel = {corbel, quarry181_strs[reveal]};
    end
  endfunction

  // ---- CONTROL: the same shape but the subroutine OWNS a local ---------
  // (`HASLOCALS`).  This one already bound before the law and must not move.
  function automatic void haslocal181_fn();
    int spandrel;
    foreach (quarry181_fixed[transom]) begin
      int corbel;
      corbel = quarry181_fixed[transom];
      spandrel = spandrel + corbel + transom;
    end
  endfunction

  // ---- CONTROL: EMPTYTF but a FORMAL, so `lm9` is non-empty anyway -----
  function automatic void hasformal181_fn(int abutment);
    foreach (quarry181_fixed[voussoir]) begin
      int corbel;
      corbel = quarry181_fixed[voussoir] + abutment;
      if (corbel > voussoir) corbel = 0;
    end
  endfunction

endpackage

package wren181_imp;
  import wren181_home::*;
  int wren181_anchor;
endpackage

module wren181_top;
  initial wren181_imp::wren181_anchor = 0;
endmodule
