// r10uvm65 arm b2_scopes.sv — the axes b1 could not carry: OUT-OF-BODY class
// method definitions (UVM is full of them), $unit scope, interface, program,
// pure virtual / extern / DPI (no body at all), a NULL-STATEMENT body, an
// inherited empty override, and the end label written WITHOUT SPACES.
//
// b1 established: FUNCTION only (not task) · end label REQUIRED · body must be
// COMPLETELY empty (a block-item declaration kills it) · `new` excluded ·
// class/module/package all fire.  b2 tests the rest.

// ---- d01/d02: $unit scope
function void d01_unit_lbl();
endfunction : d01_unit_lbl                                  // d01
task d02_unit_lbl();
endtask : d02_unit_lbl                                      // d02

// ---- d03: null-statement body (`;` IS a statement)
function void d03_nullstmt();
  ;
endfunction : d03_nullstmt                                  // d03

// ---- d04: end label with NO SPACES around the colon
function void d04_nospace();
endfunction:d04_nospace                                     // d04

virtual class b2c;
  // ---- d05/d06: EXTERN declaration + OUT-OF-BODY definition
  extern function void d05_oob();
  extern task d06_oob_t();
  // ---- d07: pure virtual — NO body syntax at all
  pure virtual function void d07_pure();
  // ---- d08: in-body empty, for the same-class control
  function void d08_inbody();
  endfunction : d08_inbody                                  // d08
endclass

function void b2c::d05_oob();
endfunction : d05_oob                                       // d05

task b2c::d06_oob_t();
endtask : d06_oob_t                                         // d06

// ---- d09/d10: derived class overriding with an empty body
class b2base;
  virtual function void d09_v();
  endfunction : d09_v                                       // d09
endclass
class b2der extends b2base;
  virtual function void d09_v();
  endfunction : d09_v                                       // d10 (override)
endclass

// ---- d11/d12: interface scope
interface b2i;
  function void d11_if_lbl();
  endfunction : d11_if_lbl                                  // d11
  task d12_if_t();
  endtask : d12_if_t                                        // d12
endinterface

// ---- d13/d14: program scope
program b2prog;
  function void d13_pg_lbl();
  endfunction : d13_pg_lbl                                  // d13
  initial begin
  end
endprogram

// ---- d15: automatic lifetime keyword written
class b2c2;
  function automatic void d15_auto();
  endfunction : d15_auto                                    // d15
endclass

// ---- d17/d18: a module that INSTANTIATES, so the def AND elab views both
// carry the empty-bodied function
module b2sub;
  function void d17_sub();
  endfunction : d17_sub                                     // d17
endmodule
module b2top;
  b2sub u1();
  b2sub u2();
  function void d18_top();
  endfunction : d18_top                                     // d18
endmodule
