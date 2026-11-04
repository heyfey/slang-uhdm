// § lvIdxMemberSelIsRead184: a member-select read nested in an lvalue index inside a function, and as an indexed part-select base
typedef struct packed { logic [3:0] f; } s_t;
module top;
  s_t s;
  logic [15:0] arr;
  int i;
  function automatic void wr(int k);
    arr[s.f[k]] = 1'b1;
  endfunction
  initial arr[s.f[(i)] +: 2] = 2'b01;
endmodule
