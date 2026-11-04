// § vsIpsBaseNamesByIps147
module top (input logic [1:0] b, input logic [1:0][7:0] w, output logic [1:0][1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    always_comb begin
      o[i] = w[i][b + 1 +: 2];
    end
  end
endmodule
