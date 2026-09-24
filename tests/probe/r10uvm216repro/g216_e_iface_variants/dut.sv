// r10uvm216 ARM E — THE VARIANT SWEEP inside an interface: a TASK export, an
// export carrying an explicit C IDENTIFIER (`export "DPI-C" cid = function f;`),
// an export whose definition IMMEDIATELY follows it (the adjacent case, which
// is the only one uvm_pkg's `m__uvm_report_dpi` exercises), and an export named
// on the SAME item list as a `modport`.  Each cell says whether the law's
// position/field rule survives the variation.
interface e216_if();
   // adjacent export + definition — the calibrated-agreeing case
   export "DPI-C" function e216_adjacent;
   function void e216_adjacent(int p);
   endfunction

   // an export carrying an explicit C identifier
   export "DPI-C" e216_cid_c = function e216_cid;

   // a TASK export
   export "DPI-C" task e216_task;

   int e216_state;

   function void e216_plain1(int p);
      e216_state = p;
   endfunction

   modport mp (import e216_plain1);

   function void e216_cid(input int a);
      e216_state = a;
   endfunction

   task e216_task(input int a);
      e216_state = a;
   endtask
endinterface

module e216_top();
   e216_if u_if();
endmodule
