// § undefaultedDefInvalidInst404
typedef enum logic [1:0] { A, B, C } st_e;
module dut #(parameter st_e S) (output logic [1:0] y);
  assign y = S;
endmodule
module top; endmodule
