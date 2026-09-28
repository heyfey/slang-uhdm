// (r11u191 const call) cast targets: int, enum, bit vector, byte, logic scalar typedef, packed struct typedef, integer
module top (output int o1, output int o2, output int o3, output int o4, output int o5, output int o6, output int o7);
  typedef enum logic [3:0] { E0, E1, E5 = 5 } e_t;
  typedef bit [7:0] b8_t;
  typedef logic [7:0] l8_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function automatic int g1(logic [11:0] x); g1 = int'(x);      endfunction
  function automatic int g2(logic [3:0] x);  g2 = e_t'(x);      endfunction
  function automatic int g3(logic [11:0] x); g3 = b8_t'(x);     endfunction
  function automatic int g4(logic [11:0] x); g4 = byte'(x);     endfunction
  function automatic int g5(logic [11:0] x); g5 = l8_t'(x);     endfunction
  function automatic int g6(logic [11:0] x); g6 = s_t'(x);      endfunction
  function automatic int g7(logic [11:0] x); g7 = integer'(x);  endfunction
  assign o1 = g1(12'h123);
  assign o2 = g2(4'd5);
  assign o3 = g3(12'h123);
  assign o4 = g4(12'h123);
  assign o5 = g5(12'h123);
  assign o6 = g6(12'h123);
  assign o7 = g7(12'h123);
endmodule
