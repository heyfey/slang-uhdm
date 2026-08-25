// r10v143 arm L — the $unit (compilation-unit) home and the INSTANCE-COUNT
// axis: one module carrying an in-body class method, instantiated 1, 2 and 3
// times; plus a $unit free function, a $unit class (in-body and out-of-body).
class Lump; int tally; int gauge; endclass

Lump uTbl[int];
task lunit_tk(int k = 0);                    // a $unit FREE task
  if (uTbl[k].tally == 0) $display("lunit_tk");
endtask

class LunitC;                                // a $unit CLASS
  Lump tbl[int];
  task lu_in(int k = 0);                     // in-body
    if (tbl[k].tally == 0) $display("lu_in");
  endtask
  extern task lu_oob(int k = 0);
endclass
task LunitC::lu_oob(int k = 0);              // out-of-body at $unit scope
  if (tbl[k].tally == 0) $display("lu_oob");
endtask

module leafL143v #(parameter int LW = 1) ();
  Lump mTbl[int];
  task lm_tk(int k = 0);
    if (mTbl[k].tally == 0) $display("lm_tk");
  endtask
  class LleafC;
    Lump tbl[int];
    task lc_tk(int k = 0);
      if (tbl[k].tally == 0) $display("lc_tk");
    endtask
    extern task lc_oob(int k = 0);
  endclass
  task LleafC::lc_oob(int k = 0);
    if (tbl[k].tally == 0) $display("lc_oob");
  endtask
  LleafC lc;
  initial begin lc = new(); lc.lc_tk(); lc.lc_oob(); lm_tk(); end
endmodule

module oneL143v; leafL143v #(1) a1 (); endmodule
module twoL143v; leafL143v #(2) b1 (); leafL143v #(3) b2 (); endmodule

module topL143v;
  oneL143v u_one();
  twoL143v u_two();
  leafL143v #(4) c1 ();
  leafL143v #(5) c2 ();
  leafL143v #(6) c3 ();
  LunitC lu;
  initial begin lu = new(); lu.lu_in(); lu.lu_oob(); lunit_tk(); end
endmodule
