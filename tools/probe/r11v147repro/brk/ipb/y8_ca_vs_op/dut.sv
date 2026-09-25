// § vsIpsBaseNamesByIps147
module top (input logic [2:0] k, input logic [1:0][7:0] w, output logic [1:0] o);
  assign o = w[1][k + 1 +: 2];
endmodule
