// § vsIpsBaseNamesByIps147
typedef struct packed { logic [2:0] k; logic v; } s_t;
module top (input s_t sv, input logic [1:0][7:0] w, output logic [1:0] o);
  always_comb begin : blk
    o = w[0][sv.k +: 2];
  end
endmodule
