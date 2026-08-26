// v98 V6 -- NAMES THE WALK MUST NOT SEE.  bindVariable reads a module_inst's
// Variables() and Nets() ONLY.  slang's Scope::find could hand back things
// Surelog never lists: an IMPORTED package variable, a variable declared
// inside an ancestor's always block, a PROGRAM ancestor's variable, a
// CHECKER-ish scope, an ancestor's TASK/FUNCTION local.  Every one of these
// must leave golden's bindings ALONE -- unbinding any of them is an AWAY.
package v6pkg98;
  logic p_imp;                   // reachable in the ancestor by `import *`
endpackage
module v6leaf98 (input logic clk, input logic [1:0] a, output logic o);
  if (1) begin : gen_b
    logic [1:0] y1, y2;
    logic p_imp;      // name exists in an ancestor only via a wildcard import
    logic p_blk;      // name exists in an ancestor's always-block scope
    logic p_task;     // name exists in an ancestor task's locals
    logic p_impl;     // name exists in the ancestor as an IMPLICIT net
    logic p_real;     // a real ancestor net -- the positive control
    assign p_imp  = (y1 == y2);
    assign p_blk  = (y1 != y2);
    assign p_task = (y1 <  y2);
    assign p_impl = (y1 >  y2);
    assign p_real = (y1 <= y2);
    assign o = p_imp ^ p_blk ^ p_task ^ p_impl ^ p_real;
    always_ff @(posedge clk) begin y1 <= a; y2 <= y1; end
  end
endmodule
module v6sink98 (input logic x, output logic y);
  assign y = x;
endmodule
module v6_notmine98 (input logic clk, input logic [1:0] a, output logic o);
  import v6pkg98::*;
  logic p_real;                             // the POSITIVE control (d1 net)
  assign p_real = 1'b0;
  always_ff @(posedge clk) begin : blkA
    logic p_blk;                            // block-local only
    p_blk <= a[0];
  end
  task automatic t98();
    logic p_task;                           // task-local only
    p_task = 1'b0;
  endtask
  v6sink98 u_sink (.x(a[0]), .y(p_impl));   // p_impl: IMPLICIT net at d1
  v6leaf98 u_leaf (.clk(clk), .a(a), .o(o));
endmodule
