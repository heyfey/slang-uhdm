// r10uvm153 arm B — THE POSITIONS AND THE FENCES.  One out-of-body
// package-scope method reads ONE colliding class property from every position
// the corpus offers, plus the three shapes § 148 / § 109 recorded as
// deliberately BARE (a hier_path element, a call receiver, a `= new` lvalue).
// LHS is always golden (Surelog).
package pb153;

  class Kb153;
    int fb;
    function void kb(); endfunction
  endclass

  int    b_int;
  string b_str;
  Kb153  b_h;
  Kb153  b_recv;
  Kb153  b_newv;

  class Db153;
    int    b_int;      // collides with the package int
    string b_str;      // collides with the package string
    Kb153  b_h;        // collides with the package handle  (hier_path fence)
    Kb153  b_recv;     // collides                           (receiver fence)
    Kb153  b_newv;     // collides                           (`= new` fence)
    int    b_free;     // collides with NOTHING
    extern function void fb153(int p);
    extern task tb153(int p);
  endclass

  function void Db153::fb153(int p);
    int b_loc;
    b_int = p;                          // 1 plain LVALUE
    p = b_int;                          // 2 plain RVALUE
    if (b_int == 1) p = 2;              // 3 if PREDICATE
    while (b_int == 2) p = 3;           // 4 while CONDITION
    case (b_int)                        // 5 case SELECTOR
      1: p = 4;
      default: p = 5;
    endcase
    p = (b_int == 1) ? 6 : 7;           // 6 TERNARY operand
    $display("%0d", b_int);             // 7 SYSTEM-CALL argument
    b_loc = kb153(b_int);               // 8 CALL ARGUMENT
    b_str = "s";                        // 9 a colliding STRING property
    b_free = p;                         // 10 collides with nothing -> BARE
    b_h.fb = p;                         // 11 HIER-PATH element  (fence)
    b_recv.kb();                        // 12 CALL RECEIVER      (fence)
    b_newv = new();                     // 13 `= new` LVALUE     (fence)
    begin
      int b_inner;
      b_inner = b_int;                  // 14 inside a nested BEGIN
    end
    for (int i = 0; i < 2; i++)
      b_int = i;                        // 15 a for BODY
    assert (b_int != 99);               // 16 immediate ASSERTION
  endfunction

  task Db153::tb153(int p);
    b_int = p;                          // 17 an out-of-body TASK
    b_free = p;                         // 18 nothing to bind
  endtask

  function int kb153(int q);
    kb153 = q;
  endfunction

endpackage
