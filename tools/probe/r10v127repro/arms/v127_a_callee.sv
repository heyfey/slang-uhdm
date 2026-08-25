// r10v127 VERIFIER grid A — CALLEE KINDS reached from the DIRECT `return` of an
// OUT-OF-BODY package class method (the window r10uvm127 opens).  Every callee
// is a DPI-C import or reaches one, so no call folds away.  MEASUREMENT ONLY.
package Wicketgate;
  import "DPI-C" function int gateProbe(int hasp);
  function automatic int gateReach(int hasp);
    return gateProbe(hasp);
  endfunction
endpackage

package Thornapple;
  import "DPI-C" function int burlWeigh(int hasp);
  import "DPI-C" function int mordentPair(string vane, int hasp);
  import "DPI-C" task   pelmetSink(int hasp);

  function automatic int freeReach(int hasp);
    return burlWeigh(hasp);
  endfunction

  class Quillon;
    int    ownHasp = 3;
    static int statHasp = 9;
    extern function int      selfCall (int hasp);
    extern function int      staticCal(int hasp);
    extern function int      sysCall  (int hasp);
    extern function int      crossPkg (int hasp);
    extern function int      handleCal(int hasp);
    extern function int      helperFn (int hasp);
    extern static function int statMeth(int hasp);
    extern task              taskBody (int hasp);
  endclass

  class Trundle;
    extern function int inner(int hasp);
  endclass
  function int Trundle::inner(int hasp);
    return burlWeigh(hasp);
  endfunction

  function int Quillon::helperFn(int hasp);
    return burlWeigh(hasp);
  endfunction

  // a call to ANOTHER method of the SAME class, written bare
  function int Quillon::selfCall(int hasp);
    return helperFn(hasp);
  endfunction

  // a STATIC method call written with the class-scope operator
  function int Quillon::statMeth(int hasp);
    return burlWeigh(hasp);
  endfunction
  function int Quillon::staticCal(int hasp);
    return Quillon::statMeth(hasp);
  endfunction

  // a SYSTEM function call: no Io_decls at all
  function int Quillon::sysCall(int hasp);
    return $clog2(hasp);
  endfunction

  // a call into ANOTHER package, written with the scope operator
  function int Quillon::crossPkg(int hasp);
    return Wicketgate::gateReach(hasp);
  endfunction

  // a call on an OBJECT HANDLE (method_func_call)
  function int Quillon::handleCal(int hasp);
    Trundle tr = new();
    return tr.inner(hasp);
  endfunction

  // a TASK body: a DPI task call as a statement, no return expression
  task Quillon::taskBody(int hasp);
    pelmetSink(hasp);
  endtask
endpackage


module Thornapple_top;
  import Thornapple::*;
  Quillon qn;
  int got;
  initial begin
    qn = new();
    got = qn.selfCall(4);
  end
endmodule
