// § vsIpsBaseNamesByIps147
typedef struct packed { logic [1:0][7:0] w; } s_t;
module top (input logic [2:0] k, input s_t s, output logic [1:0] o);
  always_comb begin : blk
    o = s.w[1][k + 1 +: 2];
  end
endmodule
