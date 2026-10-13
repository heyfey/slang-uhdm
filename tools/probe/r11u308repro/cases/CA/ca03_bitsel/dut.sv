// § nonTrailIdxRvalueOnly308
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(output logic o);
  localparam int K = 1;
  bi b[2]();
  assign b[K+1-1].v[1] = 1'b0;
  assign o = b[1].v[1];
endmodule
