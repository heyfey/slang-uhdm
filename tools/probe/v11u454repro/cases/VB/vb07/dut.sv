// § unpackedDimBasedLitKept454
module top #(parameter N = 2);
  for (genvar g = 0; g < N; g++) begin : gb
    logic [3:0] v [3'd3:0];
    assign v[0] = g;
  end
  int mx [2'd1:0][3'h2:0];
  int sz [32'd1_0:0];
  int sg [3'sd2:-3'sd1];
  initial begin mx[0][0] = 1; sz[0] = 1; sg[0] = 1; end
endmodule
