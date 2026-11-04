// § incDecMemberSelIsLvalue184 (controls): an inc/dec of a plain select, of a member without a select, and a member select as a read inside an inc/dec index
typedef struct packed { logic [7:0] f; } s_t;
module top;
  s_t s;
  logic [7:0] arr;
  int i;
  initial begin
    arr[i]++;
    s.f++;
    arr[s.f[i]]++;
    i = s.f[i] + 1;
  end
endmodule
