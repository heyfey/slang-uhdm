// § vsIpsBaseNamesByIps147
module top (input logic [2:0] b, input logic [7:0] w, output logic [3:0] o);
  assign o = w[{b[2], 2'b00}+:4];
endmodule
