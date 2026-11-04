// § vsIpsBaseNamesByIps147
module top (input logic [2:0] b, input logic s, output logic [1:0][7:0] o);
  logic [1:0][7:0] w;
  always_comb begin : blk
    w = '0;
    if (s) w[0][{b[2], 2'b00}+:4] = '1;
  end
  assign o = w;
endmodule
