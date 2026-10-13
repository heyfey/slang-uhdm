// § nonTrailIdxRvalueOnly308
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module src(output logic y); assign y = 1'b1; endmodule
module dut(output logic o);
  localparam int K = 1;
  bi b[2]();
  src u(.y(b[K-1].w));
  assign o = b[0].w;
endmodule
