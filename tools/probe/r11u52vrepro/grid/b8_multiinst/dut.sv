// b8 — the INTERFACE twin at THREE instances with three different overrides,
// plus a module-body typedef whose element bound names a parameter that is
// itself overridden per instance.  The law shares one definition-compiled
// element object across instances and clones per reference; if the clone
// carried an instance-specific VALUE this is where it shows.
interface ifc #(parameter int N = 4, parameter int DEPTH = 8) (input logic clk);
  typedef logic [N-1:0] imem_t [DEPTH];
  imem_t a;
  modport mp (input clk);
endinterface

module leaf #(parameter int N = 4, parameter int DEPTH = 8) (
  input logic clk, output logic o
);
  typedef logic [N-1:0] mem_t [DEPTH];
  mem_t mem;
  assign o = mem[0][0];
endmodule

module dut (input logic clk, output logic [2:0] o);
  ifc #(.N(4),  .DEPTH(8)) f1 (.clk(clk));
  ifc #(.N(9),  .DEPTH(2)) f2 (.clk(clk));
  ifc #(.N(16), .DEPTH(5)) f3 (.clk(clk));
  leaf #(.N(4))  l1 (.clk(clk), .o(o[0]));
  leaf #(.N(9))  l2 (.clk(clk), .o(o[1]));
  leaf #(.N(16)) l3 (.clk(clk), .o(o[2]));
endmodule
