// § unpStructArrElemVar412
module top();
  struct {int X,Y,Z;} XYZ = '{3{1}};
  struct {int X;} n;
  typedef struct {int a; logic [1:0] b;} t_t;
  t_t ti = '{1, 2'b01};
  t_t tn;
  struct {logic [1:0] q;} lq = '{2'b10};
endmodule
