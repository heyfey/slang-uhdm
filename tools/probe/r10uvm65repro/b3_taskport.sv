// r10uvm65 arm b3_taskport.sv — THE COUNTEREXAMPLE ARM.
//
// The whole-design per-cell audit of SimpleUVM found TWO golden cells my b1/b2
// "FUNCTION ONLY" term cannot explain:
//
//   1798  task uvm_reg_block::readmemh(string filename);
//   1799     // TODO
//   1800  endtask: readmemh          golden: begin @1800:10-1800:18 == `readmemh`
//
// Every b1/b2 TASK cell was golden-bare — and every one of them was written
// `task foo();` with EMPTY PARENS, i.e. with NO `tf_port_list` NODE.  readmemh
// has a real formal.  Two candidate discriminators, and this arm separates them
// cell by cell:
//   (T1) a written, NON-EMPTY tf_port_list
//   (T2) an OUT-OF-BODY (class-qualified) definition
// and one more the function side might hide:
//   (T3) the FUNCTION's own analogue — a function with NO WRITTEN RETURN TYPE
//        has one fewer node too, exactly the off-by-one
//        § constructorBodyElementShift27 measures.

package b3p;

  class b3c;
    // ---- e01 vs e02: tf_port_list PRESENT vs ABSENT, in-body task
    task e01_t_port(int a);
    endtask : e01_t_port                                    // e01
    task e02_t_noport();
    endtask : e02_t_noport                                  // e02
    // ---- e08: a port but NO end label
    task e08_t_port_nolbl(int a);
    endtask                                                 // e08
    // ---- e07: the function control, port present
    function void e07_f_port(int a);
    endfunction : e07_f_port                                // e07
    // ---- e12/e13: FUNCTION with NO WRITTEN RETURN TYPE vs `void`
    function e12_f_noret(int a);
    endfunction : e12_f_noret                               // e12
    function void e13_f_void(int a);
    endfunction : e13_f_void                                // e13
    // ---- e16: function, no return type, NO port either
    function e16_f_noret_noport();
    endfunction : e16_f_noret_noport                        // e16
    // ---- e06/e10: extern prototypes for the OUT-OF-BODY definitions below
    extern task e06_t_oob_port(int a);
    extern task e10_t_oob_noport();
    extern function void e17_f_oob_port(int a);
  endclass

  // ---- e06: OOB task WITH a port  (the corpus shape, uvm_reg_block::readmemh)
  task b3c::e06_t_oob_port(int a);
  endtask : e06_t_oob_port                                  // e06

  // ---- e10: OOB task WITHOUT a port
  task b3c::e10_t_oob_noport();
  endtask : e10_t_oob_noport                                // e10

  // ---- e17: OOB function WITH a port
  function void b3c::e17_f_oob_port(int a);
  endfunction : e17_f_oob_port                              // e17

  // ---- e04: package-scope task with a port
  task e04_t_pkg_port(int a);
  endtask : e04_t_pkg_port                                  // e04

endpackage

// ---- e05: $unit-scope task with a port
task e05_t_unit_port(int a);
endtask : e05_t_unit_port                                   // e05

// ---- e03/e18: module-scope task, port present / absent
module b3m;
  task e03_t_mod_port(int a);
  endtask : e03_t_mod_port                                  // e03
  task e18_t_mod_noport();
  endtask : e18_t_mod_noport                                // e18
  // ---- e19: module function, no written return type
  function e19_f_mod_noret(int a);
  endfunction : e19_f_mod_noret                             // e19
endmodule

// ---- e09: interface task with a port
interface b3i;
  task e09_t_if_port(int a);
  endtask : e09_t_if_port                                   // e09
endinterface

// ---- e20: a task with a port list written as `input int a` (explicit
// direction — a DIFFERENT tf_port_list shape)
module b3m2;
  task e20_t_dir(input int a);
  endtask : e20_t_dir                                       // e20
  // ---- e21: `task automatic` with a port
  task automatic e21_t_auto(int a);
  endtask : e21_t_auto                                      // e21
endmodule

// ---- e22..e27: the CONSTRUCTOR axis (c13 `function new(); endfunction : new`
// was golden-bare, and functions otherwise fire regardless of their port list —
// so is the excluded thing "the constructor" or "a PORTLESS constructor"?),
// plus a VIRTUAL task and a task with a written lifetime.
package b3p2;
  class b3c2;
    function new(int a);
    endfunction : new                                       // e22 (ctor + port)
    virtual task e23_t_virt(int a);
    endtask : e23_t_virt                                    // e23
    task automatic e24_t_autom(int a);
    endtask : e24_t_autom                                   // e24
  endclass
  class b3c3;
    function new();
    endfunction : new                                       // e25 (ctor, no port)
  endclass
  class b3c4;
    extern function new(int a);
  endclass
  function b3c4::new(int a);
  endfunction : new                                         // e26 (OOB ctor + port)
endpackage

// ---- e27/e28: NO PARENS AT ALL (legal SV, and a DIFFERENT syntax node from
// `()`: slang builds a FunctionPortList for the written parens even when it
// holds no ports, so the gate's test must be "ports NON-EMPTY", not "portList
// present").
module b3m3;
  function void e27_f_noparens;
  endfunction : e27_f_noparens                              // e27
  task e28_t_noparens;
  endtask : e28_t_noparens                                  // e28
endmodule
