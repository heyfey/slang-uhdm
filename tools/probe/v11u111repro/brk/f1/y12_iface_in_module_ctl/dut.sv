package q;
  typedef logic [3:0] mask_t;
endpackage
interface bus_if #(parameter q::mask_t M = 4'h2) (input logic clk);
  logic [3:0] d;
  assign d = M;
endinterface
module dut (input logic clk, output logic [3:0] o);
  bus_if #(.M(4'h6)) bi (.clk(clk));
  assign o = bi.d;
endmodule
