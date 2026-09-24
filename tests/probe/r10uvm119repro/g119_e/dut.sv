// arm E — what the with-block REFERENCES: locals, formals, class properties,
// a nested constraint, an empty block
class txn_e;
  rand int unsigned e_one;
  rand int unsigned e_two;
  int unsigned e_cap;
endclass

class drv_e;
  txn_e it_e;
  int unsigned prop_e;
  task run_e(int unsigned formal_e);
    int unsigned local_e;
    local_e = 5;
    // references a LOCAL
    if (!it_e.randomize() with { e_one < local_e; }) prop_e = 1;
    // references the enclosing class PROPERTY
    if (!it_e.randomize() with { e_one > prop_e; }) prop_e = 2;
    // references a FORMAL
    if (!it_e.randomize() with { e_two == formal_e; }) prop_e = 3;
    // references the RECEIVER's own property, unqualified and qualified
    if (!it_e.randomize() with { e_one < e_cap; e_two inside {2, 4, 6}; }) prop_e = 4;
    // an EMPTY constraint block
    if (!it_e.randomize() with { }) prop_e = 5;
    // a nested/implication constraint
    if (!it_e.randomize() with { if (e_one > 3) e_two < 8; else e_two > 1; }) prop_e = 6;
  endtask
endclass

module top_e;
  drv_e d_e;
  initial begin
    d_e = new();
    d_e.run_e(7);
  end
endmodule
