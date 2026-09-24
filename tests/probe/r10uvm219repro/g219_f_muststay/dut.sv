// r10uvm219 grid arm F — THE WIDER MUST-STAY CONTROL, r10uvm217 arm F's shape
// (§ oobCtorLocalsRideTheImport203 at multiplicity 2 and 3) with a bare `this`
// in a class method that NO module lists: § thisImplicitNetBoth38's predicate
// needs the routine in a module listing, so the class here is NEVER imported
// into a module and nothing may move.
package pf0;
  int f0_own0;
  class Cf0;
    extern function new();
    int f0_prop;
  endclass
  function Cf0::new();
    int f0_loc_a;
    string f0_loc_b;
    begin
      int f0_loc_c;
      f0_prop = f0_loc_c;
    end
    f0_prop = f0_loc_a;
    $display("%p", this);
  endfunction
  string f0_own1;
endpackage

module gf_noimport;
  logic gf_clk;
  initial $dumpvars(0, gf_noimport);
endmodule
