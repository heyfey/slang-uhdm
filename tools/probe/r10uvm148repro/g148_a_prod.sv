// r10uvm148 arm A — THE PRODUCTION x REFERENCE-ROLE GRID.
// MEASUREMENT ONLY.  Every subroutine below lives in a package that declares
// package-scope variables with the SAME NAMES as the subroutine's own body
// locals, so every reference is a shadow race.  The arm varies the PRODUCTION
// (paren-less function / paren function / task with body io / ANSI task) and
// the ROLE (lvalue, read, call argument, system-call argument, receiver,
// index, top-level predicate, nested predicate).
//
// Names are deliberately UNRELATED to one another (no a_t/b_t/c_t grid) and
// the declaration ORDER of the package variables is not the reference order.
package prodpkg148;

  // the shadowed package-scope names, declared in a scrambled order
  string  vane;
  int     quill;
  int     ridge;
  string  marlow;

  class Chime148;
    int val;
    function int bump(int k); val = val + k; return val; endfunction
  endclass

  function int helper148(int z); return z + 7; endfunction

  // ---- TF-ITEM (paren-less function): locals land on the task_func ONLY ----
  function void tf_roles148;
    int    quill;
    string vane;
    int    ridge;
    quill = 4;                       // LVALUE
    vane  = "cornice";               // LVALUE
    ridge = quill + 2;               // READ (rhs) + LVALUE
    ridge = helper148(quill);        // ARG (user call)
    $display("%0d %s", ridge, vane); // ARG (system call)
    if (quill == 4)                  // COND at BODY TOP LEVEL -> early bound
      ridge = 1;
    while (ridge < 3) begin          // a loop STATEMENT in the chain
      if (quill > 0)                 // COND nested under a loop -> late bound
        ridge = ridge + 1;
    end
  endfunction

  // ---- BLOCK-ITEM (paren function): locals are dual-listed on the begin ----
  function void bi_roles148();
    int    quill;
    string vane;
    int    ridge;
    quill = 4;
    vane  = "architrave";
    ridge = quill + 2;
    ridge = helper148(quill);
    $display("%0d %s", ridge, vane);
    if (quill == 4)
      ridge = 1;
    while (ridge < 3) begin
      if (quill > 0)
        ridge = ridge + 1;
    end
  endfunction

  // ---- TASK, TF-ITEM (the body declares io) --------------------------------
  task tf_task148;
    input int seed;
    int    marlow;
    string vane;
    marlow = seed;
    vane   = "gable";
    marlow = helper148(marlow);
    $display("%s", vane);
    if (marlow == 9) marlow = 0;
  endtask

  // ---- TASK, BLOCK-ITEM (ANSI header) --------------------------------------
  task bi_task148(input int seed);
    int    marlow;
    string vane;
    marlow = seed;
    vane   = "soffit";
    marlow = helper148(marlow);
    $display("%s", vane);
    if (marlow == 9) marlow = 0;
  endtask

  // ---- the RECEIVER and INDEX roles, both productions ----------------------
  Chime148 tocsin;
  int      lintel [4];

  function void tf_recv148;
    Chime148 tocsin;
    int      lintel [4];
    int      quill;
    tocsin = new();
    quill  = tocsin.bump(3);         // RECV (method receiver)
    lintel[quill] = 5;               // IDX inside an LVALUE select
    quill  = lintel[2];              // IDX inside a READ select
  endfunction

  function void bi_recv148();
    Chime148 tocsin;
    int      lintel [4];
    int      quill;
    tocsin = new();
    quill  = tocsin.bump(3);
    lintel[quill] = 5;
    quill  = lintel[2];
  endfunction

  // ---- a name that is a LOCAL with NO package twin (the negative control) ---
  function void tf_noshadow148;
    int  burin;
    burin = 11;
    $display("%0d", burin);
  endfunction
endpackage

module prodtop148;
  import prodpkg148::*;
  initial begin
    tf_roles148();
    bi_roles148();
    tf_task148(3);
    bi_task148(3);
    tf_recv148();
    bi_recv148();
    tf_noshadow148();
  end
endmodule
