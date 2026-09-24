module top #(parameter logic [63:0] M = 64'hDEADBEEF_12345678) (input logic s, output logic [7:0] o);
  assign o = s ? M[7:0] : '0;
endmodule
