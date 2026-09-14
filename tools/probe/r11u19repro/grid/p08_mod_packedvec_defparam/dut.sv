module top #(parameter int P = 1) (input logic [31:0] a, output logic [7:0] we);
  assign we = '{default: P};
endmodule
