// vbuvm19 adversarial grid B — SHAPES, QUALIFICATIONS, LHS FORMS, ANCESTORS.
// All cells are package-homed out-of-body class methods or package free
// functions: the window the law claims.  Every cell is one written token away
// from a converting cell.
package vbp19;

  typedef struct packed { bit [3:0] f19; bit [3:0] g19; } vs19;
  typedef int vta19[string];
  typedef enum { E0, E1 } ve19;

  class vbase19; int z19; endclass

  class vp19;
    vbase19 pa19[int];
    int     p2d19[2][3];        // 2-D fixed
    int     pas19[string][int]; // 2-D assoc
    vs19    pst19[4];           // unpacked array of packed struct
    vta19   ptd19;              // typedef'd assoc
    int     pen19[ve19];        // assoc keyed by enum
    bit [7:0] ppk19[3];         // unpacked array of packed vector
    vbase19 pq19[$];
    int     pdy19[];

    extern function void twodsel19();
    extern function void twolv19();
    extern function void assoc2d19();
    extern function void structsel19();
    extern function void tdsel19();
    extern function void ensel19();
    extern function void rangesel19();
    extern function void membersel19();
    extern function void compound19();
    extern function void concatlhs19();
    extern function void nestedfe19();
    extern function void shadow19();
    extern function void whileanc19();
    extern function void foranc19();
    extern function void caseanc19();
    extern function void foreveranc19();
    extern task          forkjoin19();
    extern function void afterret19();
    extern function void idxcall19();
    extern task          nbassign19();
    extern function void declouter19();
  endclass

  class vd19 extends vp19;
    extern function void supersel19();
  endclass

  // 1 — nested select on a 2-D fixed array
  function void vp19::twodsel19();
    foreach (p2d19[i]) $display("2d", i);
    p2d19[0][1] = 5;
  endfunction

  // 2 — TWO loop variables (the real 2-loop-var cell)
  function void vp19::twolv19();
    foreach (p2d19[i, j]) $display("2lv", p2d19[i][j]);
    p2d19[1][2] = 6;
  endfunction

  // 3 — 2-D associative, select assignment with one index only
  function void vp19::assoc2d19();
    foreach (pas19[i, j]) $display("a2d", pas19[i][j]);
    pas19["k"][2] = 7;
  endfunction

  // 4 — unpacked array of packed structs
  function void vp19::structsel19();
    foreach (pst19[i]) $display("st", pst19[i]);
    pst19[1] = '{default:0};
  endfunction

  // 5 — typedef'd associative array
  function void vp19::tdsel19();
    foreach (ptd19[i]) $display("td", ptd19[i]);
    ptd19["z"] = 8;
  endfunction

  // 6 — associative keyed by an ENUM
  function void vp19::ensel19();
    foreach (pen19[i]) $display("en", pen19[i]);
    pen19[E1] = 9;
  endfunction

  // 7 — a RANGE (part) select on the LHS
  function void vp19::rangesel19();
    foreach (ppk19[i]) $display("pk", ppk19[i]);
    ppk19[0][3:0] = 4'h5;
  endfunction

  // 8 — a MEMBER select on the LHS
  function void vp19::membersel19();
    foreach (pa19[i]) $display("mb", pa19[i]);
    pa19[2].z19 = 3;
  endfunction

  // 9 — a COMPOUND assignment through a select
  function void vp19::compound19();
    foreach (pdy19[i]) $display("cp", pdy19[i]);
    pdy19[0] += 1;
  endfunction

  // 10 — a CONCATENATION left-hand side holding the select
  function void vp19::concatlhs19();
    int t19;
    foreach (ppk19[i]) $display("cc", ppk19[i]);
    {ppk19[1], t19} = 16'h0;
  endfunction

  // 11 — a NESTED foreach: the inner one's ancestor chain carries the outer
  function void vp19::nestedfe19();
    foreach (pa19[i]) begin
      foreach (pq19[j]) $display("nf", pq19[j]);
    end
    pq19[0] = null;
  endfunction

  // 12 — an inner block DECLARES a same-named local; the assignment is on it
  function void vp19::shadow19();
    foreach (pa19[i]) $display("sh", pa19[i]);
    begin
      int pa19[int];
      pa19[0] = 1;
    end
  endfunction

  // 13..16 — other ancestor STATEMENT kinds holding the foreach
  function void vp19::whileanc19();
    int n19 = 0;
    while (n19 < 2) begin
      foreach (pa19[i]) $display("wh", pa19[i]);
      n19++;
    end
    pa19[3] = null;
  endfunction

  function void vp19::foranc19();
    for (int n19 = 0; n19 < 2; n19++) begin
      foreach (pa19[i]) $display("fo", pa19[i]);
    end
    pa19[4] = null;
  endfunction

  function void vp19::caseanc19();
    case (pa19.size())
      0: begin
           foreach (pa19[i]) $display("ca", pa19[i]);
         end
      default: $display("d");
    endcase
    pa19[5] = null;
  endfunction

  function void vp19::foreveranc19();
    fork
      forever begin
        foreach (pa19[i]) $display("fv", pa19[i]);
      end
    join_none
    pa19[6] = null;
  endfunction

  // 17 — a fork..join (not join_none) ancestor
  task vp19::forkjoin19();
    fork
      begin
        foreach (pq19[i]) $display("fj", pq19[i]);
      end
    join
    pq19[1] = null;
  endtask

  // 18 — the select assignment is AFTER a return
  function void vp19::afterret19();
    foreach (pdy19[i]) $display("ar", pdy19[i]);
    return;
  endfunction

  // 19 — the select INDEX is a function call
  function void vp19::idxcall19();
    foreach (pa19[i]) $display("ic", pa19[i]);
    pa19[$size(pdy19)] = null;
  endfunction

  // 20 — a NONBLOCKING select assignment in a task
  task vp19::nbassign19();
    foreach (ppk19[i]) $display("nb", ppk19[i]);
    ppk19[0] <= 8'h2;
  endtask

  // 21 — the array is declared in an OUTER block, assigned in an INNER one
  function void vp19::declouter19();
    int dl19[string];
    begin
      foreach (dl19[i]) $display("do", dl19[i]);
      dl19["q"] = 1;
    end
  endfunction

  // 22 — the select assignment written with an explicit `super.` prefix
  function void vd19::supersel19();
    foreach (pa19[i]) $display("su", pa19[i]);
    super.pa19[8] = null;
  endfunction

  // 23 — a package variable assigned through its PACKAGE-QUALIFIED name
  int pgq19[string];
  function void qualsel19();
    foreach (pgq19[i]) $display("qs", pgq19[i]);
    vbp19::pgq19["r"] = 2;
  endfunction

  // 24 — a package variable, bare select, package free function (positive)
  int pgb19[string];
  function void baresel19();
    foreach (pgb19[i]) $display("bs", pgb19[i]);
    pgb19["s"] = 3;
  endfunction
endpackage
