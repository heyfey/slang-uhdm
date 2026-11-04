// § spanCopyCarriesFile125
module top(output logic [1:0] o);
  typedef struct packed { logic [3:0] f; } t_t;
  t_t arr [2:0] = '{4'h1, 4'h2, 4'h3};
  assign o = arr[1].f[2 +: 2];
endmodule
