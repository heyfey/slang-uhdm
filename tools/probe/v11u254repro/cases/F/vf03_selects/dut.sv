// § forInitSelectLhsBase254 (a packed struct member, an indexed part-select, a 2-D element, an index that is a variable, two initializers)
typedef struct packed { logic [3:0] a; logic [3:0] b; } ps_t;
module top(output int o);
  ps_t s;
  logic [7:0] v;
  int m [2][3];
  int arr [4];
  int i, j;
  initial begin
    o = 0;
    for (s.b = 0; s.b < 3; s.b++) o++;
    for (v[0 +: 4] = 0; v[0 +: 4] < 2; v[0 +: 4]++) o++;
    for (m[1][2] = 0; m[1][2] < 2; m[1][2]++) o++;
    j = 1;
    for (arr[j+1] = 0; arr[j+1] < 2; arr[j+1]++) o++;
    for (s.a = 0, i = 0; s.a < 2; s.a++) o++;
  end
endmodule
