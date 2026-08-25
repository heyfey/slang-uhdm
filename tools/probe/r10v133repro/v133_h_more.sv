// r10v133 arm H - the HOMES the other arms do not reach: constraints,
// assertions, covergroups, inheritance (super.), a virtual method, a static
// method, a function ARGUMENT, a return expression, a delay, a stream and an
// inside-set.  MEASUREMENT ONLY.
package pv133h;
  class base133h;
    int bq[$];
    function int bf133(); return 1; endfunction
  endclass

  class der133h extends base133h;
    rand int rv;
    int      dq[$];
    string   ds;
    static function int sf133(); return 2; endfunction
    virtual function int vf133(); return 3; endfunction

    constraint c133 { rv < $bits(dq.size()); }        // H01 constraint block

    covergroup cg133;
      cp133 : coverpoint rv { bins b1 = {[0:$bits(dq.size())]}; }   // H02 covergroup
    endgroup

    function new(); cg133 = new(); endfunction

    function int arg133(int k); return k; endfunction

    function int probe133();
      int r;
      r = $bits(super.bf133());        // H03 super-qualified call
      r = $bits(vf133());              // H04 virtual method call
      r = $bits(sf133());              // H05 static method call
      r = arg133($bits(dq.size()));    // H06 as a call ARGUMENT
      r = $bits(der133h::sf133());     // H07 class-scoped static call
      if (r inside {$bits(dq.size()), 3}) r = 4;   // H08 inside-set element
      assert (r < $bits(dq.size()));   // H09 immediate assertion
      case ($bits(dq.size()))          // H10 case EXPRESSION
        1 : r = 1;
        default : r = 2;
      endcase
      while (r < $bits(dq.size())) r++;  // H11 loop condition
      return $bits(dq.size());           // H12 return expression
    endfunction
  endclass
endpackage

module vm133h;
  import pv133h::*;
  int r;
  int hq[$];
  function automatic int hf133(); return 7; endfunction
  initial begin
    #($bits(hf133())) r = 1;             // H13 delay control
    r = {<<{$bits(hf133())}};            // H14 stream operand
  end
endmodule
