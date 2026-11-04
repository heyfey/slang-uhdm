// § vsIpsBaseNamesByIps147
module top (input logic [2:0] b, input logic [2:0] k, input logic [1:0] s, output logic [1:0][7:0] o, output logic [1:0] q);
  logic [1:0][7:0] w;
  always_comb begin : blk
    w = '0;
    q = '0;
    unique case (s)
      2'b00: q = w[0][k + 1 +: 2];
      default: w[0] = '1;
    endcase
  end
  assign o = w;
endmodule
