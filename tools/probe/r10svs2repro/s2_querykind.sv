// r10svs2 ARM s2 — WHICH built-in methods golden treats the parens-less way.
// One statement per query, all parens-less, so the arm answers "is the law about
// `size` or about the whole QUERY CLASS?".
//
// MEASURED HERE: size, sum, product (array REDUCTIONS), and the LOCATOR methods
// min/max/unique parens-less (their result is a QUEUE, so they are assigned to a
// queue -- `d.min[0]` is a Surelog SYNTAX ERROR, which is itself a measurement
// and is recorded in the README).
// NOT MEASURED HERE (stated plainly in the README): find / find_index /
// find_first / find_last, which need a `with` clause and so always carry parens;
// reverse / sort / rsort / shuffle, which are VOID array-ORDERING methods and
// only appear in statement position.
class qy;
  int d[];
  int q[$];
  int mq[$];

  function int f();
    int a, b, c, e;
    a  = d.size;         // ARRAY QUERY on a dynamic array
    b  = q.size;         // QUEUE query
    c  = d.sum;          // ARRAY REDUCTION, parens-less
    e  = d.product;      // ARRAY REDUCTION, parens-less
    mq = d.min;          // LOCATOR, no with-clause, parens-less
    mq = d.max;          // LOCATOR, no with-clause, parens-less
    mq = d.unique;       // LOCATOR, no with-clause, parens-less
    return a + b + c + e;
  endfunction

  function int g();      // POSITIVE CONTROLS: the same six WITH parens
    int a, b, c, e;
    a  = d.size();
    b  = q.size();
    c  = d.sum();
    e  = d.product();
    mq = d.min();
    mq = d.unique();
    return a + b + c + e;
  endfunction
endclass

module top;
  qy o;
  initial begin
    o = new();
    $display("%0d %0d", o.f(), o.g());
  end
endmodule
