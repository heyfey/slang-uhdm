// r10earl32 arm 1 — THE CALL-KIND AXIS.
//
// Origin held at the Earlgrey witness's exactly: a PACKAGE localparam
// `logic [11:0] P12 = 12'h380` (dm_pkg.sv:34), read QUALIFIED, in a module
// that does NOT import the package.  Only the CALL changes.
//
// The head: dm_mem.sv:365 `dm::load(ac_ar.aarsize, 5'd8, 5'd10, dm::DataAddr)`
// where golden folds the 4th argument to `constant 12'h380 @365:75-365:87` and
// we keep `ref_obj (dm::DataAddr) @365:75-365:79` (the `dm::` qualifier span).
package k32;
  localparam logic [11:0] P12 = 12'h380;
  localparam logic [11:0] Q12 = 12'h123;

  function automatic logic [31:0] pf(logic [2:0] sz, logic [11:0] off);
    return {off, sz, 17'h0};
  endfunction
endpackage

// no `import k32::*` anywhere in this module — the witness's shape.
module k32a (
  input  logic [2:0]  sz_i,
  input  logic        c_i,
  output logic [31:0] o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12
);
  function automatic logic [31:0] mf(logic [2:0] sz, logic [11:0] off);
    return {off, sz, 17'h0};
  endfunction
  function automatic logic [11:0] id12(logic [11:0] v);
    return v;
  endfunction
  task automatic mt(input logic [11:0] off, output logic [31:0] r);
    r = {off, 20'h0};
  endtask

  class kc;
    function automatic logic [31:0] m(logic [11:0] off);
      return {off, 20'h0};
    endfunction
    static function automatic logic [31:0] sm(logic [11:0] off);
      return {off, 20'h1};
    endfunction
  endclass

  logic [31:0] r1, r2, r3, r4, r5, r6, r7, r8;

  // ------------------------------------------------------------------ c1..c4
  // c1  PACKAGE function, qualified call, qualified arg — THE WITNESS SHAPE
  assign o1 = k32::pf(sz_i, k32::P12);                       // c1
  // c2  MODULE-LOCAL function, cont_assign
  assign o2 = mf(sz_i, k32::P12);                            // c2
  // c3  MODULE-LOCAL TASK call (procedural only)
  // c4  sys_func_call — the r10earl31 e1 o8 negative control, re-measured here
  assign o3 = 32'(($clog2(k32::P12)));                       // c4

  always_comb begin
    r1 = k32::pf(sz_i, k32::P12);                            // c5 pkg fn, process
    r2 = mf(sz_i, k32::P12);                                 // c6 module fn, process
    mt(k32::P12, r3);                                        // c3 TASK CALL
    r4 = mf(sz_i, k32::P12 + 12'h1);                         // c7 arg is an OPERATION
    r5 = mf(sz_i, id12(k32::P12));                           // c8 NESTED call arg
    r6 = kc::sm(k32::P12);                                   // c9 STATIC class method
    r7 = mf(sz_i, c_i ? k32::P12 : k32::Q12);                // c10 ternary arg
    r8 = mf(sz_i, {4'h0, k32::P12[7:0]});                    // c11 part-select of it
  end
  assign o4 = r1; assign o5 = r2; assign o6 = r3; assign o7 = r4;
  assign o8 = r5; assign o9 = r6; assign o10 = r7; assign o11 = r8;

  // c12  a call INSIDE A FUNCTION BODY
  function automatic logic [31:0] outer(logic [2:0] sz);
    return mf(sz, k32::P12);                                 // c12
  endfunction
  assign o12 = outer(sz_i);
endmodule

// c13 — the SAME witness shape in a module that IMPORTS the package, read
// QUALIFIED; c14 the same read written BARE.  The import is the discriminator
// every ts-stamping arm in this codebase already keys on.
module k32b (
  input  logic [2:0]  sz_i,
  output logic [31:0] o1, o2
);
  import k32::*;
  function automatic logic [31:0] mf(logic [2:0] sz, logic [11:0] off);
    return {off, sz, 17'h0};
  endfunction
  assign o1 = mf(sz_i, k32::P12);                            // c13 qualified + import
  assign o2 = mf(sz_i, P12);                                 // c14 BARE + import
endmodule

// c15 — a module that is NEVER INSTANTIATED: only the DEF listing exists, so
// this is the "is the fold only in an elaborated body?" control.
module k32c (
  input  logic [2:0]  sz_i,
  output logic [31:0] o1
);
  function automatic logic [31:0] mf(logic [2:0] sz, logic [11:0] off);
    return {off, sz, 17'h0};
  endfunction
  assign o1 = mf(sz_i, k32::P12);                            // c15
endmodule

module k32top;
  logic [2:0] sz;
  logic c;
  logic [31:0] a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,b1,b2;
  k32a ua (.sz_i(sz), .c_i(c), .o1(a1), .o2(a2), .o3(a3), .o4(a4), .o5(a5),
           .o6(a6), .o7(a7), .o8(a8), .o9(a9), .o10(a10), .o11(a11), .o12(a12));
  k32b ub (.sz_i(sz), .o1(b1), .o2(b2));
endmodule
