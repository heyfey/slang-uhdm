// § ppOutputCol166 (one-line expansions)
`define SZ                   9                       // 512
`define HI                   `SZ-1        // 8
`define TAGL                 `HI+1       // 9
module top(input [31:0] a, output logic [31:0] q);
  always_comb q[31:`TAGL] = a[31:`TAGL];
endmodule
