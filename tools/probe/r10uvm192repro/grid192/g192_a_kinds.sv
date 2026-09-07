// r10uvm192 ARM A — THE CALLEE KIND x THE CALLER SITE, one package.
// § pkgTfBodyCmViewClone192.  MEASUREMENT ONLY; the official uhdm-cmp judges.
// Every call below is written CLASS-QUALIFIED, the spelling the law is about,
// except the two free-function rows, which are § pkgDefCallBindsOwnListing173's
// population and must keep whatever 173 gave them.
package kilnPkg;

  // a0 — a free package function.  The `kilnPkg::` row is 173's cell.
  function automatic int emberCount();
    return 3;
  endfunction

  class Vessel;
    int shard;
    // a1 — an IN-BODY static function: the package listing has no `C::m`
    //      entry for it, so nothing can move.
    static function int gaugeInBody();
      return 11;
    endfunction
    // a2..a6 — extern prototypes, DEFINED OUT OF BODY below, which is what
    //          puts a `Vessel::<name>` entry in the package's DEF listing.
    extern static function int gaugeExtern();
    extern static task tallyExtern(output int q);
    extern static function int gaugeVirtualHome();
    extern function int gaugeNonStatic();
    extern function new();
    // a7 — THE CALLERS: out-of-body method bodies, the UVM shape.  The task
    //      row needs a TASK caller (a task cannot be invoked from a function).
    extern static function int caller();
    extern static task callerTask(output int q);
  endclass

  function Vessel::new();
    shard = 1;
  endfunction

  function int Vessel::gaugeExtern();
    return 13;
  endfunction

  task Vessel::tallyExtern(output int q);
    q = 17;
  endtask

  function int Vessel::gaugeVirtualHome();
    return 19;
  endfunction

  function int Vessel::gaugeNonStatic();
    return shard;
  endfunction

  // THE CALL SITE THE LAW IS ABOUT — an out-of-body method's body, which the
  // DEF listing carries as `Vessel::caller` parented at the package.
  function int Vessel::caller();
    return Vessel::gaugeExtern()            // extern out-of-body static function
         + Vessel::gaugeInBody()            // IN-BODY static function
         + Vessel::gaugeVirtualHome()       // a second extern static
         + kilnPkg::emberCount()            // PACKAGE-qualified free fn (173)
         + emberCount();                    // unqualified free fn
  endfunction

  // The TASK-CALL row: an out-of-body static TASK body calling a static task.
  task Vessel::callerTask(output int q);
    Vessel::tallyExtern(q);
  endtask

  // b1 — the same calls from a PACKAGE-LEVEL free function's body.
  function automatic int pkgCaller();
    return Vessel::gaugeExtern() + Vessel::gaugeInBody();
  endfunction

  // b2 — the same task call from a PACKAGE-LEVEL free task's body.
  task automatic pkgCallerTask(output int q);
    Vessel::tallyExtern(q);
  endtask

  // b4 — a package VARIABLE initializer: § pkgVarInitCmViewClone111's own
  //      cell.  It must be BYTE-IDENTICAL under both binaries.
  int kilnSeed = Vessel::gaugeExtern();

endpackage

module kiln_top;
  import kilnPkg::*;
  int a, b;
  // b5 — a MODULE body: no enclosing package, so the law can never reach it.
  initial begin
    a = Vessel::gaugeExtern();
    b = kilnPkg::emberCount();
  end
endmodule
