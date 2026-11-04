package p;
  typedef enum logic [2:0] {S0 = 3'd1, S1 = 3'd3, S2 = 3'd5} st_t;
  localparam int W = int'(S2) + 1;
  typedef struct packed {
    st_t        state;
    logic [W-1:0] data;
    st_t        next;
  } rec_t;
endpackage
module top(input p::rec_t i, output p::rec_t o, output p::st_t s);
  p::rec_t a, b;
  assign a = i;
  assign b = a;
  assign o = b;
  assign s = (a.state == p::S1) ? p::S2 : p::S0;
endmodule
