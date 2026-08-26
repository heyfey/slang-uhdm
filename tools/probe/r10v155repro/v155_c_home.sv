// r10v155 arm C — HOMES the implementer's grid did NOT cover: a PROGRAM, an
// INTERFACE, a task body, a nested fork, a class property (NOT a statement
// scope), a package variable, a module variable, and a class method used
// in-body and out-of-body.  MEASUREMENT ONLY.
package pkgC155v;
  // A package-level variable off a package typedef — control, must resolve.
  typedef bit [5:0] pkgVarTdC155v;
  pkgVarTdC155v pkgVarC155v;

  class HoldC155v;
    // a CLASS PROPERTY off a CLASS typedef — control, must resolve.
    typedef bit [4:0] propTdC155v;
    propTdC155v propC155v;

    function automatic void inBodyC155v();
      typedef byte inBodyTdC155v;
      inBodyTdC155v inBodyValC155v;      // ?
      inBodyValC155v = 8'd1;
    endfunction

    extern function void oobC155v();
    extern task oobTaskC155v();
  endclass

  function void HoldC155v::oobC155v();
    typedef shortint oobTdC155v;
    oobTdC155v oobValC155v;              // ?
    begin
      typedef longint oobNestTdC155v;
      oobNestTdC155v oobNestValC155v;    // ?
      oobNestValC155v = 64'd2;
    end
    oobValC155v = 16'd3;
  endfunction

  task HoldC155v::oobTaskC155v();
    typedef bit [11:0] oobTaskTdC155v;
    oobTaskTdC155v oobTaskValC155v;      // ?
    oobTaskValC155v = 12'd4;
  endtask
endpackage

program prgC155v;
  typedef bit [2:0] prgTdC155v;
  prgTdC155v prgVarC155v;                // control: program-level, resolves
  initial begin
    typedef byte prgLocalTdC155v;
    prgLocalTdC155v prgLocalValC155v;    // ?
    prgLocalValC155v = 8'd5;
  end
  task automatic prgTaskC155v();
    typedef int prgTaskTdC155v;
    prgTaskTdC155v prgTaskValC155v;      // ?
    prgTaskValC155v = 6;
  endtask
endprogram

interface ifcC155v;
  typedef bit [1:0] ifcTdC155v;
  ifcTdC155v ifcVarC155v;                // control: interface-level, resolves
  initial begin
    typedef byte ifcLocalTdC155v;
    ifcLocalTdC155v ifcLocalValC155v;    // ?
    ifcLocalValC155v = 8'd7;
  end
  function automatic int ifcFuncC155v();
    typedef shortint ifcFuncTdC155v;
    ifcFuncTdC155v ifcFuncValC155v;      // ?
    ifcFuncValC155v = 16'd8;
    return int'(ifcFuncValC155v);
  endfunction
endinterface

module mHomeC155v;
  typedef bit [9:0] modTdC155v;
  modTdC155v modVarC155v;                // control: module-level, resolves
  ifcC155v ifcInstC155v();
  pkgC155v::HoldC155v hC155v;
  initial begin
    hC155v = new();
    hC155v.inBodyC155v();
    hC155v.oobC155v();
  end
  task automatic tHomeC155v();
    typedef int taskTdC155v;
    taskTdC155v taskValC155v;            // ?
    fork
      begin
        typedef byte forkTdC155v;
        forkTdC155v forkValC155v;        // ?
        forkValC155v = 8'd9;
      end
      begin : nfC155v
        fork
          begin
            typedef shortint deepForkTdC155v;
            deepForkTdC155v deepForkValC155v;   // ?
            deepForkValC155v = 16'd10;
          end
        join_none
      end
    join_none
    taskValC155v = 11;
  endtask
endmodule
