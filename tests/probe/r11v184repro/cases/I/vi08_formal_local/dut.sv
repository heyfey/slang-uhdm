// § incDecMemberSelIsLvalue184: a member-select increment on a struct formal (inout and ref) and on an automatic local
typedef struct packed { logic [7:0] f; } s_t;
module top;
  function automatic void bump(inout s_t a, input int j);
    a.f[j]++;
  endfunction
  task automatic tb(ref s_t b, input int j);
    s_t t;
    t = b;
    t.f[j]--;
    b.f[j + 1]++;
  endtask
endmodule
