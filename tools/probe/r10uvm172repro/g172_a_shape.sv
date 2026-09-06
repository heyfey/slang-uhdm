// r10uvm172 arm A — CHAIN SHAPE, receiver = the ENCLOSING function's own name
// (its return variable).  Every cell is legal SystemVerilog in both tools.
// MEASUREMENT ONLY.
package pa172;
  class inner172;
    string q172[$];
    int    n172;
    function void seti172(int v); n172 = v; endfunction
    task    settsk172(int v); n172 = v; endtask
  endclass

  class holder172;
    string   hq172[$];
    int      hn172;
    inner172 hi172;
    string   amap172[string];
    inner172 iarr172[4];

    function holder172 cpy172();
      holder172 other172;
      cpy172 = new();
      cpy172.hi172 = new();
      other172 = new();
      other172.hi172 = new();
      cpy172.hq172.push_back("a");          // c01 two-deep builtin, one arg
      cpy172.hq172.delete();                // c02 two-deep builtin, no arg
      cpy172.hi172.seti172(3);              // c03 two-deep USER method
      cpy172.hi172.q172.push_back("b");     // c05 three-deep builtin
      cpy172.iarr172[1].seti172(5);         // c06 indexed SECOND component
      cpy172.amap172["k"] = "v";            // c07 assignment, NOT a call stmt
      cpy172.hn172 = 7;                     // c08 assignment, NOT a call stmt
      hn172 = cpy172.hq172.size();          // c09 EXPRESSION position
      if (cpy172.hq172.size() > 0)          // c10 CONDITION position
        hn172 = 1;
      other172.hq172.push_back("c");        // c11 base = ordinary local
      other172.hi172.seti172(4);            // c12 base = ordinary local
      return cpy172;
    endfunction

    // c04 — the same two-deep USER TASK call, in a TASK home (a function may
    // not call a task).
    task cpytsk172();
      holder172 cpytsk172v;
      cpytsk172v = new();
      cpytsk172v.hi172 = new();
      cpytsk172v.hi172.settsk172(9);        // c04 two-deep USER task
    endtask

    function int deep172();
      inner172 deep172x;
      deep172x = new();
      deep172x.q172.push_back("z");         // c13 base = near-miss spelling
      return 0;
    endfunction
  endclass
endpackage

module top172;
  import pa172::*;
  holder172 h172;
  initial begin
    h172 = new();
    void'(h172.cpy172());
  end
endmodule
