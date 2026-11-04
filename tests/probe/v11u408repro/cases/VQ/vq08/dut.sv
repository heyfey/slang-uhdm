// § classBoundedQueueStatic408
typedef struct packed { logic [3:0] a; } s_t;
class e; endclass
class c;
  static int q[$:2];
  s_t r[$:1];
  e o[$:3];
endclass
module top;
  c h;
  initial h = new;
endmodule
