// § lvIdxMemberSelIsRead184 (controls): the member path as the lvalue target itself, as an rvalue index, and inside a plain select in an lvalue index
typedef struct packed { logic [7:0] f; } s_t;
module top;
  s_t s, t;
  logic [7:0] arr;
  logic y;
  int i;
  initial begin
    s.f[i] = 1'b1;
    y = arr[s.f[i]];
    arr[arr[s.f[i]]] = 1'b0;
  end
endmodule
