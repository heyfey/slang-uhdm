// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o2 [2]);
  typedef struct packed { logic [15:0] a; logic [15:0] b; } st_t;
  localparam st_t C = '{a: 16'd11, b: 16'd22};
  assign o2[0] = C.a;
  assign o2[1] = C.b;
endmodule
