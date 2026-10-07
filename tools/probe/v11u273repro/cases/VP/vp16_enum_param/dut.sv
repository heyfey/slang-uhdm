// § paramValRhsSharesParamConst273
module dut (output logic [31:0] o2 [2]);
  typedef enum logic [1:0] { A0, A1, A2 } e_t;
  localparam e_t E = A2;
  assign o2[0] = E;
  assign o2[1] = '0;
endmodule
