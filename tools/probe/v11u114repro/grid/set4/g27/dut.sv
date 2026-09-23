// face-1 break: two concat members on the same line inside a nested positional pattern; plus a module copy
package q2;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  typedef struct packed { s_t x; s_t y; } t_t;
  parameter t_t IMPL = '{ '{ {4'h1, 4'h2}, {4'h3, 4'h4} }, '{ a: {2'b01, 6'h5}, b: {8{1'b1}} } };
endpackage
module top import q2::*; (output logic [7:0] o, p); assign o = IMPL.x.a; assign p = IMPL.y.b; endmodule
