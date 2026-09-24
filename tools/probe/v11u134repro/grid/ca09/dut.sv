// § contAssignLhsTsUnparented134
module top(input logic c, output logic [1:0] o);
  typedef enum logic [1:0] { IDLE, RUN, DONE } st_t;
  st_t st;
  st_t nx;
  assign st = c ? RUN : IDLE;
  always_comb nx = DONE;
  assign o = st ^ nx;
endmodule
