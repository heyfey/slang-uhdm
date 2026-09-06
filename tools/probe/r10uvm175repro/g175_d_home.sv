// r10uvm175 arm D — the HOME the `with`-clause path is written in, and the
// EXPRESSION SLOT it occupies.
package delta_mill;
  class sack;
    string stamps[$];
    int digits[$];
    function new(); endfunction
  endclass
  class hopper;
    sack chutes[$];
    int caught[$];
    string mark;
    extern function void offbody(int lane);
    function void inbody(int lane);
      // h_rhs: assignment RHS inside an IN-BODY class method
      caught = chutes[lane].stamps.find_index() with (item == mark);
    endfunction
    function void slots(int lane, int other);
      int n;
      // h_arg: inside a call ARGUMENT
      $display("%p", chutes[lane].stamps.find_index() with (item == mark));
      // h_cond: inside an IF condition
      if ((chutes[lane].digits.sum() with (item)) > 0) n = 1;
      // h_rval: an ordinary rvalue
      n = chutes[lane].digits.sum() with (item);
      // h_foreach: inside a foreach body over the same array
      foreach (chutes[k]) begin
        caught = chutes[k].stamps.find_index() with (item == mark);
      end
    endfunction
  endclass
  // h_oob: an OUT-OF-BODY class method (curSubOob9's own switch)
  function void hopper::offbody(int lane);
    caught = chutes[lane].stamps.find_index() with (item == mark);
  endfunction
  // h_pkgfn: a package FREE FUNCTION
  function automatic int freefn(hopper hp, int lane);
    int r[$];
    r = hp.chutes[lane].stamps.find_index() with (item == "x");
    return r.size();
  endfunction
endpackage
module dmod;
  import delta_mill::*;
  hopper rig;
  int got[$];
  // h_init: a module INITIAL body
  initial begin
    got = rig.chutes[1].stamps.find_index() with (item == "y");
  end
  // h_always: a module ALWAYS body
  always @(*) begin
    got = rig.chutes[2].stamps.find_index() with (item == "z");
  end
  // h_modfn: a module function
  function automatic int modfn(int lane);
    int q[$];
    q = rig.chutes[lane].stamps.find_index() with (item == "w");
    return q.size();
  endfunction
endmodule
