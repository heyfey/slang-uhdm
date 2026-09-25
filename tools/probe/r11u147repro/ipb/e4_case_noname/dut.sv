// § vsIpsBaseNamesByIps147
module top (input logic [2:0] b, input logic [1:0] s, output logic [1:0][7:0] o);
  logic [1:0][7:0] w;
  always_comb begin
    w = '0;
    unique case (s)
      2'b00: w[0][{b[2], 2'b00}+:4] = '1;
      default: w[0] = '1;
    endcase
  end
  assign o = w;
endmodule
