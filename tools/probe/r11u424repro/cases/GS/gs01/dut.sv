// § genForCompoundStep424 (bsg_pipeline_stall_collapse shape)
module top (output logic [3:0] o);
  genvar i;
  for (i = 0; i < 4; i+=1) begin : g
    assign o[i] = 1'b0;
  end
endmodule
