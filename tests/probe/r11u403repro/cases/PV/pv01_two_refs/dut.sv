// § patternVarImplicitNet403
module top();
  typedef union tagged {
    struct { bit [3:0] val1, val2; } a;
    struct { bit [7:0] val1, val2; } b;
    void n;
  } u;
  u tmp;
  bit [3:0] val;
  int x;
  initial begin
    if (tmp matches tagged a '{.*, .v}) x = v;
    if (tmp matches tagged a '{4'd0, .v}) val = v;
  end
endmodule
