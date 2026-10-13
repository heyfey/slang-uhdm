// § nonTrailIdxRvalueOnly308
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(input logic clk, output logic o, output logic [3:0] ov);
  localparam int K = 1;
  bi b[2]();
  logic x;
  assign {b[K-1].w, x} = 2'b11;
  assign o = b[0].w ^ x;
endmodule
