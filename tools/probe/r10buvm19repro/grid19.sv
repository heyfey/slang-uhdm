// r10buvm19repro/grid19.sv — the GOLDEN grid for the foreach-header array
// reference's typespec in the ELABORATED package listing.
//
// A package and nothing else, exactly BuildUVMPkg's shape (no module, so no
// $unit import and no module elaboration).  Every cell iterates a CLASS
// PROPERTY, which is the only shape our emitter mints an unsupported_typespec
// for in the elaborated view; the axes are (a) whether an ANCESTOR block of
// the foreach assigns the same name through a SELECT, (b) how far up that
// ancestor is, (c) whether the assignment's LHS is a select or the bare name,
// (d) the array's kind, (e) in-body vs out-of-body method vs free function.
package gp19;

  class base19;
    int z19;
  endclass

  class c19;
    base19 pa19[int];      // associative of class handles, int index
    base19 pq19[$];        // queue of class handles
    int    pi19[string];   // associative of int, string index
    int    pf19[4];        // fixed
    int    pd19[];         // dynamic
    bit    pb19[base19];   // associative of bit, CLASS index

    extern function void none19();
    extern function void sel19();
    extern function void bare19();
    extern function void deep19();
    extern function void outer19();
    extern function void qsel19();
    extern function void before19();
    extern function void isel19();
    extern function void fsel19();
    extern function void dsel19();
    extern function void bsel19();
    extern function void othersel19();
    extern function void insidebody19();
    extern function void twolv19();

    // an IN-BODY method with the very same shape as sel19
    function void inbody19();
      foreach (pa19[k]) begin
        if (pa19[k] != null) $display("x");
      end
      pa19[7] = null;
    endfunction
  endclass

  // a1 — foreach and NOTHING else: no ancestor assigns the name
  function void c19::none19();
    foreach (pa19[k]) begin
      if (pa19[k] != null) $display("a");
    end
  endfunction

  // a2 — the BuildUVMPkg shape: a SELECT assignment in the SAME block
  function void c19::sel19();
    foreach (pa19[k]) begin
      if (pa19[k] != null) $display("b");
    end
    pa19[7] = null;
  endfunction

  // a3 — the same statement written with the BARE name on the left
  function void c19::bare19();
    base19 other19[int];
    foreach (pa19[k]) begin
      if (pa19[k] != null) $display("c");
    end
    pa19 = other19;
  endfunction

  // a4 — the select assignment is DEEPER than the foreach (inside its body):
  //      not an ancestor block at all
  function void c19::deep19();
    foreach (pa19[k]) begin
      pa19[k] = null;
    end
  endfunction

  // a5 — the select assignment sits TWO blocks up
  function void c19::outer19();
    begin : outerblk19
      begin : innerblk19
        foreach (pa19[k]) begin
          if (pa19[k] != null) $display("d");
        end
      end
      pa19[9] = null;
    end
  endfunction

  // a6 — a QUEUE property with a select assignment
  function void c19::qsel19();
    foreach (pq19[k]) begin
      if (pq19[k] != null) $display("e");
    end
    pq19[0] = null;
  endfunction

  // a7 — the select assignment is written BEFORE the foreach
  function void c19::before19();
    pa19[3] = null;
    foreach (pa19[k]) begin
      if (pa19[k] != null) $display("f");
    end
  endfunction

  // a8..a11 — the other array kinds
  function void c19::isel19();
    foreach (pi19[k]) begin
      $display("g", pi19[k]);
    end
    pi19["z"] = 1;
  endfunction

  function void c19::fsel19();
    foreach (pf19[k]) begin
      $display("h", pf19[k]);
    end
    pf19[1] = 1;
  endfunction

  function void c19::dsel19();
    foreach (pd19[k]) begin
      $display("i", pd19[k]);
    end
    pd19[1] = 1;
  endfunction

  function void c19::bsel19();
    base19 bk19;
    foreach (pb19[k]) begin
      $display("j", pb19[k]);
    end
    pb19[bk19] = 1;
  endfunction

  // a12 — a select assignment on a DIFFERENT name
  function void c19::othersel19();
    foreach (pa19[k]) begin
      if (pa19[k] != null) $display("k");
    end
    pi19["q"] = 2;
  endfunction

  // a13 — the assignment is inside an if-branch block that is NOT an ancestor
  function void c19::insidebody19();
    foreach (pa19[k]) begin
      if (pa19[k] == null) begin
        $display("l");
      end
    end
    if (pi19["q"] == 0) begin
      pa19[11] = null;
    end
  endfunction

  // a14 — TWO loop variables over a 2-D property, with a select assignment
  function void c19::twolv19();
    foreach (pa19[k]) begin
      if (pa19[k] != null) $display("m");
    end
    pa19[13] = null;
  endfunction

  // b1 — a package-level associative variable and a package FREE function
  int pgv19[string];

  function void free19();
    foreach (pgv19[k]) begin
      $display("n", pgv19[k]);
    end
    pgv19["w"] = 3;
  endfunction

  function void freenone19();
    foreach (pgv19[k]) begin
      $display("o", pgv19[k]);
    end
  endfunction

  // b2 — a subroutine LOCAL array with a select assignment
  function void locsel19();
    int loc19[string];
    foreach (loc19[k]) begin
      $display("p", loc19[k]);
    end
    loc19["y"] = 4;
  endfunction

  // ---- second arm: formals, forks, named blocks, dotted/`this` LHS spellings
  class d19;
    base19 qa19[int];
    extern function void thissel19();
    extern function void forksel19();
    extern function void namedsel19();
    extern function void ifanc19();
  endclass

  // c1 — the select assignment written with an explicit `this.` prefix
  function void d19::thissel19();
    foreach (qa19[k]) begin
      if (qa19[k] != null) $display("q");
    end
    this.qa19[5] = null;
  endfunction

  // c2 — the select assignment sits in a FORK block that is an ancestor
  function void d19::forksel19();
    fork
      begin
        foreach (qa19[k]) begin
          if (qa19[k] != null) $display("r");
        end
      end
    join_none
    qa19[6] = null;
  endfunction

  // c3 — a NAMED ancestor block holds the assignment
  function void d19::namedsel19();
    begin : nb19
      foreach (qa19[k]) begin
        if (qa19[k] != null) $display("s");
      end
      qa19[8] = null;
    end
  endfunction

  // c4 — the foreach sits inside an if-branch block; the assignment is in the
  //      enclosing function body
  function void d19::ifanc19();
    if (qa19.size() > 0) begin
      foreach (qa19[k]) begin
        if (qa19[k] != null) $display("t");
      end
    end
    qa19[10] = null;
  endfunction

  // c5/c6 — a subroutine FORMAL array, with and without the select assignment
  function automatic void formsel19(ref base19 fa19[$]);
    foreach (fa19[k]) begin
      if (fa19[k] != null) $display("u");
    end
    fa19[0] = null;
  endfunction

  function automatic void formnone19(ref base19 fb19[$]);
    foreach (fb19[k]) begin
      if (fb19[k] != null) $display("v");
    end
  endfunction

endpackage

// d1 — THE IMPORT-CLONE ARM.  A wildcard import materializes a COPY of
// gp19::free19 inside imp19; golden's copy KEEPS the unsupported_typespec in
// BOTH of the importer's views, where gp19's own elaborated copy loses it.
package imp19;
  import gp19::*;
endpackage
