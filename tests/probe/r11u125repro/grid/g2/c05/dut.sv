// § spanCopyCarriesFile125
module top(input logic [3:0] in_i, output logic [3:0] out_o);
  typedef bit [3:0] n_t;
  typedef struct { n_t f [2]; } b_t;
  typedef b_t bb_t [3];
  bb_t v;
  assign v[0].f[0] = in_i;
  assign out_o = v[0].f[0];
endmodule
