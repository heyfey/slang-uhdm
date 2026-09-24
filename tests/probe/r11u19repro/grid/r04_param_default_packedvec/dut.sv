module top #(parameter logic [1:0] P = '{default: '0}) (input logic [31:0] a, output logic [1:0] o);
  assign o = P;
endmodule
