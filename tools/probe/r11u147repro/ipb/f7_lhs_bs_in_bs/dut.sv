// § vsIpsBaseNamesByIps147
module top (input logic [2:0] b, input logic [2:0] k, input logic [1:0] s, output logic [1:0][7:0] o, output logic [1:0] q);
  logic [1:0][7:0] w;
  always_comb begin : blk
    w = '0;
    q = '0;
    unique case (s)
      2'b00: w[0][b[k[0]] + 1 +: 2] = '1;
      default: w[0] = '1;
    endcase
  end
  assign o = w;
endmodule
