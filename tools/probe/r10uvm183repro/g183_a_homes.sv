// r10uvm183 grid ARM A — THE HOME AXIS × THE VIEW AXIS.
// One home package, a WILDCARD importer, an EXPLICIT named importer and a
// module importer, so every listing of the same `foreach` body is present in
// one database: the home package's DEF and ELABORATED copies, the wildcard
// clone's two copies, the explicit-import copy and the module's own hoist.
// The iterated object varies (formal / subroutine local / package variable /
// class property) because Surelog's resolved answer differs per home while its
// PLACEHOLDER does not.
// Names, numbers and orders are deliberately unlike the corpus'.
package hm183;
  typedef enum bit [2:0] { RED3 = 1, AMBER5 = 2, JADE7 = 4 } tint_e;

  string g_names[$];
  int    g_slots[6];

  // the FORMAL face — uvm_has_wildcard's shape
  function automatic int cnt_fml(string wrds[$]);
    cnt_fml = 0;
    foreach (wrds[k1]) cnt_fml++;
  endfunction

  // the SUBROUTINE-LOCAL face — uvm_string_to_action's shape
  function automatic int cnt_loc();
    int local_bag[$];
    cnt_loc = 0;
    local_bag.push_back(31);
    foreach (local_bag[q2]) cnt_loc += local_bag[q2];
  endfunction

  // a PACKAGE-LEVEL variable
  function automatic int cnt_pkgvar();
    cnt_pkgvar = 0;
    foreach (g_slots[z3]) cnt_pkgvar += g_slots[z3];
  endfunction

  // a STATEMENT-BLOCK local, one level in
  function automatic int cnt_blk();
    cnt_blk = 0;
    begin
      byte inner_row[3];
      foreach (inner_row[y7]) cnt_blk += inner_row[y7];
    end
  endfunction

  // a TASK, so the arm is not a function-only grid
  task automatic tsk_fml(ref int nums[4]);
    foreach (nums[w4]) nums[w4] = w4;
  endtask

  class Holder183;
    tint_e shades[];
    function int roll();
      roll = 0;
      foreach (shades[v5]) roll++;
    endfunction
  endclass
endpackage

// WILDCARD import — the clone path this pass's law owns
package wild183;
  import hm183::*;
  int seen_w = 1;
  function automatic int use_w();
    string bag[$];
    bag.push_back("gk");
    return cnt_fml(bag) + cnt_loc() + cnt_pkgvar() + cnt_blk();
  endfunction
endpackage

// EXPLICIT named import — a DIFFERENT copy path
package expl183;
  import hm183::cnt_fml;
  import hm183::cnt_blk;
  int seen_e = 2;
  function automatic int use_e();
    string sack[$];
    sack.push_back("pv");
    return cnt_fml(sack) + cnt_blk();
  endfunction
endpackage

module top183;
  import hm183::*;
  int arr8[4];
  int tally8;
  hm183::Holder183 hh;
  initial begin
    foreach (arr8[m6]) arr8[m6] = m6;
    tally8 = cnt_loc();
  end
endmodule
