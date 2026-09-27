module top;
  typedef struct packed { logic [3:0] d; } s_t;
  s_t s;
  for (genvar i = 0; i < 4; ++i) begin : g
    assign s.d[i] = 1'b0;
  end
endmodule
