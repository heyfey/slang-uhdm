// r10v192 ARM C — A CLASS WHOSE NAME EQUALS A PACKAGE NAME.  Surelog's
// getTaskFunc tries `design->getPackage(head)` FIRST, so `Twin::m` resolves to
// the PACKAGE `Twin`'s free function even inside a package that owns a CLASS
// named `Twin`.  The production fence has no package-name term.
// MEASUREMENT ONLY.
package Twin;
  function automatic int m();
    return 1;
  endfunction
  task automatic mt(output int q);
    q = 1;
  endtask
endpackage

package hostP;
  class Twin;
    extern static function int m();
    extern static task mt(output int q);
    extern static function int hostCaller();
    extern static task hostCallerT(output int q);
  endclass
  function int Twin::m();
    return 2;
  endfunction
  task Twin::mt(output int q);
    q = 2;
  endtask
  function int Twin::hostCaller();
    return Twin::m();
  endfunction
  task Twin::hostCallerT(output int q);
    Twin::mt(q);
  endtask
endpackage

module v192c_top;
  import hostP::*;
  int r;
  initial r = hostP::Twin::hostCaller();
endmodule
