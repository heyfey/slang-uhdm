// arm F — EXPRESSION POSITIONS of the member with-form
class txn_f;
  rand int unsigned f_one;
endclass

class drv_f;
  txn_f it_f;
  int unsigned r_f;
  int ok_f;
  function int chk_f();
    // under return
    return it_f.randomize() with { f_one < 30; };
  endfunction
  task run_f();
    // under ! (the corpus regime)
    if (!it_f.randomize() with { f_one > 1; }) r_f = 1;
    // DIRECT if-condition, no !
    if (it_f.randomize() with { f_one > 2; }) r_f = 2;
    // under while
    while (it_f.randomize() with { f_one > 3; }) r_f = r_f + 1;
    // a plain assignment rvalue
    ok_f = it_f.randomize() with { f_one > 4; };
    // an operand of a binary operation
    ok_f = 1 + it_f.randomize() with { f_one > 5; };
    // a ternary operand
    ok_f = (r_f > 0) ? it_f.randomize() with { f_one > 6; } : 0;
    // inside a $display argument
    $display("%0d", it_f.randomize() with { f_one > 7; });
  endtask
endclass

module top_f;
  drv_f g_f;
  initial begin
    g_f = new();
    g_f.run_f();
  end
endmodule
