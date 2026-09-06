// r10uvm172 arm D — HOW FAR THE NAME SEARCH REACHES, and the ONE-DEEP chain.
// Each cell writes the same statement on a local whose spelling is a
// subroutine name declared at one more distant scope.  MEASUREMENT ONLY.
function automatic int unitfn172();      // $unit-scope free function
  return 1;
endfunction

package pg172;
  function int impfn172(); return 1; endfunction
endpackage

package ph172;                            // NOT imported anywhere
  function int noimpfn172(); return 1; endfunction
endpackage

package pi172;
  import pg172::*;

  class base172;
    string bq172[$];
    int    bn172;
    function void basefn172(); endfunction
    function void bpush172(string s); bq172.push_back(s); endfunction
  endclass

  class der172 extends base172;
    function void dprobe172();
      base172 basefn172;      // d01 an INHERITED base-class method name
      base172 unitfn172;      // d02 a $unit free function name
      base172 impfn172;       // d03 an imported package function name
      base172 noimpfn172;     // d04 a NOT-imported package function name
      base172 modfn172;       // d05 a MODULE function name
      basefn172  = new(); basefn172.bq172.push_back("d01");
      unitfn172  = new(); unitfn172.bq172.push_back("d02");
      impfn172   = new(); impfn172.bq172.push_back("d03");
      noimpfn172 = new(); noimpfn172.bq172.push_back("d04");
      modfn172   = new(); modfn172.bq172.push_back("d05");
    endfunction

    // d06/d07 — the ONE-DEEP chain: the receiver IS the collapsing name and
    // the call is written directly on it, with REAL arguments.
    function void donedeep172();
      string donedeep172q[$];
      base172 dpush172;
      donedeep172q.push_back("d06");      // d06 base = THIS function's name
      dpush172 = new();
      dpush172.bpush172("d07");           // d07 base = a base-class method name
    endfunction

    // d08 — a FOUR-component chain.
    function base172 dfour172();
      dfour172 = new();
      dfour172.bq172.push_back("d08");
      return dfour172;
    endfunction
  endclass
endpackage

module topd172;
  import pi172::*;
  function int modfn172(); return 1; endfunction
  der172 d172;

  // d09 — a MODULE task whose local names the module's own function.
  task modprobe172();
    base172 modfn172v;
    base172 topdtask172;
    modfn172v   = new(); modfn172v.bq172.push_back("d09a");
    topdtask172 = new(); topdtask172.bq172.push_back("d09b");
  endtask
  task topdtask172(); endtask

  initial begin
    d172 = new();
    d172.dprobe172();
    modprobe172();
  end
endmodule
