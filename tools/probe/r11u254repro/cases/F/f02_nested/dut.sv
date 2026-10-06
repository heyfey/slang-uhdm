// § forInitSelectLhsBase254 (a nested struct member and a member of an unpacked array element as the for-loop initializer target)
typedef struct { int a; } i_t;
typedef struct { i_t t; int b; } s_t;
module top(output int o);
  s_t s; s_t sa [2];
  initial begin
    o = 0;
    for (s.t.a = 0; s.t.a < 4; s.t.a++) o = o + 1;
    for (sa[1].b = 0; sa[1].b < 2; sa[1].b++) o = o + 1;
  end
endmodule
