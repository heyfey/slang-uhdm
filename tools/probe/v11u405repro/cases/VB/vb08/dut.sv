// § blockParamWrittenRhs405
module top(output logic [3:0] o);
always_comb begin : b
  localparam logic [3:0] M = 4'b1x0z;
  localparam N = M;
  o = N;
end
endmodule
