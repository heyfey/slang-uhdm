// § vsIpsBaseNamesByIps147
module top (input logic [1:0] b, input logic [1:0][7:0] w, output logic [1:0] o);
  always_comb begin : blk
    o = w[0][~b[0] +: 2];
  end
endmodule
