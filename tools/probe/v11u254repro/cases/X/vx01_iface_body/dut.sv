// § hcSelIdxTsSkipsPort254 (interface bodies: an interface instance connection with an imported index, a replication count and a package-qualified two-level select inside the interface)
package pk;
  parameter int unsigned PMP_D = 1;
  parameter int N = 2;
  parameter logic [1:0][3:0][7:0] R3 = '1;
endpackage
interface sub (input logic a);
endinterface
interface ifc #(parameter int W = 1) (input logic clk);
  import pk::*;
  logic [2:0] e;
  logic [3:0] q;
  logic [7:0] r;
  sub u (.a(e[PMP_D]));
  always_ff @(posedge clk) begin : p_i
    q <= {N{2'b10}};
  end
  assign r = pk::R3[W][0];
endinterface
module top (input logic clk);
  ifc i (.clk(clk));
endmodule
