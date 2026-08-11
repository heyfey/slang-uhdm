// r10svs2 VERIFIER ARM w4 — BUILT-IN CLASS/RANDOMIZE methods and the LOCATORS
// WITH a `with` clause.  The implementer's s2 explicitly did NOT measure
// find/find_index (they need `with`), and no arm measured randomize /
// constraint_mode / rand_mode, which are built-in CLASS methods reaching the
// SAME method_func_call site the law now swaps.  `randomize` parens-less is
// legal and is the widest-reach unmeasured cell in the whole set (UVM).
class w4;
  rand int a;
  int q[$];
  constraint c { a > 0; }

  function int f();
    int r;
    int ql[$];
    r  = randomize;              // (1) built-in CLASS method, receiver-less, NO parens
    r  = r + randomize();        // (2) POSITIVE CONTROL: with parens
    r  = r + this.randomize;     // (3) same via `this.`, NO parens
    r  = r + this.randomize();   // (4) POSITIVE CONTROL
    ql = q.find_index with (item > 2);  // (5) LOCATOR w/ `with`, no arg parens
    ql = q.find with (item > 2);        // (6) LOCATOR w/ `with`, no arg parens
    ql = q.find_first with (item > 2);  // (7) LOCATOR w/ `with`, no arg parens
    r  = r + q.sum with (item);         // (8) REDUCTION w/ `with`, no arg parens
    return r;
  endfunction

  task g();
    c.constraint_mode(0);   // (9) built-in constraint method, parens-ful, stmt
    a.rand_mode(0);         // (10) built-in rand method, parens-ful, stmt
  endtask
endclass

module top;
  w4 o;
  initial begin
    o = new();
    o.g();
    $display("%0d", o.f());
  end
endmodule
