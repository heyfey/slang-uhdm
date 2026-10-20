// § structMemberDefault414
module top;
  typedef struct { logic [7:0] b = 8'hAB; bit c = 1'b1; } s_t;
  s_t s;
endmodule
