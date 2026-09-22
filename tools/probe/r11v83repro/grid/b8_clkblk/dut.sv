// v11u83 b8 -- LAW A: a named CLOCKING BLOCK over a hoisted namesake.
// emitNamedClockingBlocks reads netMap; the hoist now puts a package
// namesake in it.
package pk;
  logic [7:0] cv;
endpackage

interface ifc (input logic clk);
  import pk::*;
  logic [15:0] cv;
  clocking cb @(posedge clk);
    input cv;
  endclocking
  logic [15:0] r;
  assign r = cv;
endinterface

module dut (input logic clk, output logic [31:0] o);
  ifc u_if (.clk(clk));
  assign o = {16'd0, u_if.r};
endmodule
