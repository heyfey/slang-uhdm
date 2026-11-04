// § spanCopyCarriesFile125
module top(input logic [7:0] din, output logic [5:0] o);
  typedef struct packed { logic [1:0] y; } s_t;
  typedef s_t [2:0] sa_t;
  assign o = sa_t'(din);
endmodule
