// r10v145 arm A -- EVERY LOCAL-INITIALISER FACE x PRODUCTION.
// TF-ITEM = paren-less function, or a task whose body declares io.
// BLOCK-ITEM twin = the same body written with a port-list paren (function)
// or without body io (task).  MEASUREMENT ONLY.
package pa145v;

  class Ka145v;
    int f;
    static function int sget(); return 7; endfunction
    function new(); f = 1; endfunction
  endclass

  function automatic int helpa145v(); return 3; endfunction

  // ================= TF-ITEM (paren-less function) =================
  function void tfi_lit145v;
    static int s1 = 11;
    automatic int a1 = 12;
    int n1 = 13;
    $display(s1, a1, n1);
    $display(s1);
  endfunction

  function void tfi_call145v;
    int c1 = helpa145v();
    int c2 = Ka145v::sget();
    $display(c1, c2);
    $display(c1);
  endfunction

  function void tfi_new145v;
    Ka145v k1 = new();
    Ka145v k2 = null;
    $display(k1 == k2);
    $display(k2 == null);
  endfunction

  function void tfi_multi145v;
    int m1 = 1, m2, m3 = 3;
    $display(m1, m2, m3);
    $display(m2);
  endfunction

  function void tfi_inner145v;
    int o1 = 1;
    begin : bl145v
      int i1 = 2;
      $display(i1);
      $display(i1 + 1);
    end
    $display(o1);
  endfunction

  // ================= BLOCK-ITEM twins (paren function) =================
  function void bit_lit145v();
    static int s1 = 11;
    automatic int a1 = 12;
    int n1 = 13;
    $display(s1, a1, n1);
    $display(s1);
  endfunction

  function void bit_call145v();
    int c1 = helpa145v();
    int c2 = Ka145v::sget();
    $display(c1, c2);
    $display(c1);
  endfunction

  function void bit_new145v();
    Ka145v k1 = new();
    Ka145v k2 = null;
    $display(k1 == k2);
    $display(k2 == null);
  endfunction

  function void bit_multi145v();
    int m1 = 1, m2, m3 = 3;
    $display(m1, m2, m3);
    $display(m2);
  endfunction

  function void bit_inner145v();
    int o1 = 1;
    begin : bl2145v
      int i1 = 2;
      $display(i1);
      $display(i1 + 1);
    end
    $display(o1);
  endfunction

  // ================= TASKS =================
  // TF-ITEM task: body io declaration
  task tski_io145v;
    input int p;
    static int t1 = 21;
    automatic int t2 = 22;
    Ka145v t3 = new();
    $display(p, t1, t2);
    $display(t3 == null);
  endtask

  // TF-ITEM task with a FORK carrying its own local
  task tski_fork145v;
    input int p;
    int f1 = 31;
    fork
      begin : fk145v
        int q1 = 32;
        $display(q1);
      end
    join_none
    $display(f1, p);
  endtask

  // BLOCK-ITEM task twins (no body io)
  task tsbi_noio145v(input int p);
    static int t1 = 21;
    automatic int t2 = 22;
    Ka145v t3 = new();
    $display(p, t1, t2);
    $display(t3 == null);
  endtask

  task tsbi_fork145v(input int p);
    int f1 = 31;
    fork
      begin : fk2145v
        int q1 = 32;
        $display(q1);
      end
    join_none
    $display(f1, p);
  endtask

  // a non-void FUNCTION, both productions
  function int tfi_ret145v;
    int r1 = 41;
    int r2 = r1 + 1;
    $display(r1);
    return r2;
  endfunction

  function int bit_ret145v();
    int r1 = 41;
    int r2 = r1 + 1;
    $display(r1);
    return r2;
  endfunction

endpackage
