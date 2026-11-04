// § nonTrailIdxRvalueOnly308
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(output logic o);
  bi b[4]();
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar k = 0; k < 2; k++) begin : q
      assign b[i*2+k].w = 1'b0;
    end
  end
  assign o = b[1].w;
endmodule
