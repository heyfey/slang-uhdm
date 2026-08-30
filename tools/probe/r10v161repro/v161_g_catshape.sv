// r10v161 ARM G — pinning the CONCATENATION predicate.  Arm F showed a
// reference whose immediate parent is a `vpiConcatOp` (#33) is golden-BARE,
// EXCEPT when that concat is itself the operand of a `vpiMultiConcatOp` (#34),
// where golden BINDS.  This arm asks whether that exception is the
// replication or something else, across every concat nesting.
// MEASUREMENT ONLY.  LHS golden (Surelog), RHS ours.
class Cat_g161;
  int prop = 1;
  function int helper(int z); return z; endfunction

  function void g_shapes(int formal_g);
    bit [3:0] a = 0, b = 0;
    int loc = 1;
    assert ({a} == 0);                        // g01 a ONE-element concat
    assert ({a, b} == 0);                      // g02 a two-element concat
    assert ({{a, b}, a} == 0);                 // g03 a concat INSIDE a concat
    assert ({2{a}} == 0);                      // g04 a replication of a name
    assert ({2{{a, b}}} == 0);                 // g05 a replication of a CONCAT
    assert ({2{a}} == {2{b}});                 // g06 two replications
    assert ({a, {2{b}}} == 0);                 // g07 a replication inside a concat
    assert (helper({a, b}) == 0);              // g08 a concat as a CALL argument
    assert ($bits({a, b}) == 8);               // g09 a concat as a SYS-CALL argument
    assert (int'({a, b}) == 0);                // g10 a concat under a CAST
    assert ({a, b} inside {8'h00});            // g11 a concat as an `inside` operand
    assert (loc == 1 && {a, b} == 0);          // g12 a concat under a logical AND
    assert ({a + b, b} == 0);                  // g13 an OPERATION inside a concat
    assert ({a, formal_g[3:0]} == 0);          // g14 a part select inside a concat
    // the same shapes in the `if` COLUMN
    if ({a} == 0) prop = 1;                    // g21
    if ({2{a}} == 0) prop = 1;                 // g22
    if ({2{{a, b}}} == 0) prop = 1;            // g23
    if ({a, {2{b}}} == 0) prop = 1;            // g24
    if (helper({a, b}) == 0) prop = 1;         // g25
    if (int'({a, b}) == 0) prop = 1;           // g26
  endfunction
endclass

module top_g161;
  Cat_g161 cg;
  initial cg = new();
endmodule
