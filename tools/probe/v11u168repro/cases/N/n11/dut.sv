// § ppBasedLitWsAfter166
`define PDEF(n) \
  localparam logic [7:0] n = 8'h 1f; \
  localparam logic [3:0] n``_b = 4'b 1010;
module top(output logic [7:0] y, output logic [3:0] z);
  `PDEF(K)
  assign y = K;
  assign z = K_b;
endmodule
