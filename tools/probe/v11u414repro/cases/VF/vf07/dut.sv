// § unitFwdTypedefTwin414
typedef t;
typedef union packed { logic [1:0] a; bit [1:0] b; } t;
module top;
  t x;
endmodule
