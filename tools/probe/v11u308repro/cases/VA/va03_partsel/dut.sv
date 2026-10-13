// § nonTrailIdxRvalueOnly308
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(input logic clk, output logic o, output logic [3:0] ov);
  localparam int K = 1;
  bi b[2]();
  logic x;
  assign b[K-1].v[1:0] = 2'b01;
  assign ov = b[0].v;
endmodule
