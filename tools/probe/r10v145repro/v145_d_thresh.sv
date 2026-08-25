// r10v145 arm D -- THE THRESHOLD.  N initialised locals x M real statements,
// N,M in 0..3, under BOTH productions; plus the parameter-bearing TF-ITEM
// task (the one face where the patch changes the eff9==0 branch), a body that
// IS one explicit begin, and an uninitialised-local control.
// MEASUREMENT ONLY.
package pd145v;

  // ---------------- TF-ITEM (paren-less function) ----------------
  function void n0m1145v;                 $display(1);                       endfunction
  function void n0m2145v;                 $display(1); $display(2);          endfunction
  function void n1m0145v;  int a = 1;                                        endfunction
  function void n1m1145v;  int a = 1;     $display(a);                       endfunction
  function void n1m2145v;  int a = 1;     $display(a); $display(a+1);        endfunction
  // n2m0 / n3m0 (2+ inits, 0 statements) live in arm G: they SEGFAULT the
  // pristine binary, so a database for this arm would not exist at all.
  function void n2m1145v;  int a = 1; int b = 2;  $display(a,b);             endfunction
  function void n2m2145v;  int a = 1; int b = 2;  $display(a); $display(b);  endfunction
  function void n3m3145v;  int a = 1; int b = 2; int c = 3;
                           $display(a); $display(b); $display(c);            endfunction
  // uninitialised-local controls (initCount==0)
  function void u1m1145v;  int a;         $display(a);                       endfunction
  function void u2m1145v;  int a; int b;  $display(a,b);                     endfunction
  function void u2m0145v;  int a; int b;                                     endfunction

  // ---------------- BLOCK-ITEM twins (paren) ----------------
  function void b0m1145v();               $display(1);                       endfunction
  function void b1m0145v(); int a = 1;                                       endfunction
  function void b1m1145v(); int a = 1;    $display(a);                       endfunction
  function void b2m0145v(); int a = 1; int b = 2;                            endfunction
  function void b2m1145v(); int a = 1; int b = 2; $display(a,b);             endfunction
  function void b2m2145v(); int a = 1; int b = 2; $display(a); $display(b);  endfunction
  function void bu2m1145v(); int a; int b; $display(a,b);                    endfunction

  // ---------------- body that IS one explicit begin ----------------
  function void tfi_expl145v;
    begin
      int e1 = 1;
      $display(e1);
      $display(e1 + 1);
    end
  endfunction

  function void bit_expl145v();
    begin
      int e1 = 1;
      $display(e1);
      $display(e1 + 1);
    end
  endfunction

  // ---------------- a for-loop variable ----------------
  function void tfi_for145v;
    int s = 0;
    for (int i = 0; i < 3; i++) s += i;
    $display(s);
  endfunction

endpackage

// ---------------- the PARAMETER-bearing bodies ----------------
module mp145v;
  // TF-ITEM task (body io) + a body parameter + N inits + M stmts
  task tp_n1m0145v;
    input int p;
    parameter PP = 7;
    int a = 1;
  endtask

  task tp_n1m1145v;
    input int p;
    parameter PP = 7;
    int a = 1;
    $display(a, p, PP);
  endtask

  task tp_n0m1145v;
    input int p;
    parameter PP = 7;
    $display(p, PP);
  endtask

  // BLOCK-ITEM task twins (no body io)
  task tb_n1m0145v(input int p);
    parameter PP = 7;
    int a = 1;
  endtask

  task tb_n1m1145v(input int p);
    parameter PP = 7;
    int a = 1;
    $display(a, p, PP);
  endtask

  // paren-less FUNCTION with a body parameter (TF-ITEM)
  function void fp_n1m0145v;
    parameter QQ = 5;
    int a = 1;
  endfunction

  function void fp_n1m1145v;
    parameter QQ = 5;
    int a = 1;
    $display(a, QQ);
  endfunction
endmodule
