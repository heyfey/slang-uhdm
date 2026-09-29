// § hpTrailIpsNamesByPath218
typedef struct packed { logic [31:0] a_data; logic v; } tl_t;
module top(input tl_t tl, output logic [3:0][7:0] o);
  always_comb
    for (int i = 0; i < 4; i++)
      o[i] = tl.a_data[8*i +: 8];
endmodule
