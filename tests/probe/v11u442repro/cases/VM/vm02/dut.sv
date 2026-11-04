// § clsTdFirstSameClass442v
class C;
endclass
module aa;
  typedef struct packed { logic [3:0] f; } C_s;
  typedef C_s C;
  typedef C d_t;
  d_t g;
endmodule
module top;
  typedef C c_t;
  c_t h;
  aa u();
endmodule
