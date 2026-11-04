// § nonTrailIdxRvalueOnly308
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(input logic clk, output logic o, output logic [3:0] ov);
  localparam int K = 1;
  bi b[2]();
  logic x;
  for (genvar gi = 0; gi < 2; gi++) begin : g
    logic z; assign z = b[gi+1-1].w;
  end
  assign o = g[0].z;
endmodule
