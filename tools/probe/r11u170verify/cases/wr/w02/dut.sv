// § withRecvOnlyLastScoped157
typedef struct { int arr[4]; } s_t;
typedef struct { s_t in; } w_t;
module top;
  w_t w; int r; int q[$];
  initial begin
    r = w.in.arr.sum() with (item * 2);
    q = w.in.arr.find with (item > 1);
  end
endmodule
