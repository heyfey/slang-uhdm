// § incDecMemberSelIsLvalue184: a member-select increment on an implicit-this class property and on a handle chain
typedef struct packed { logic [7:0] f; } s_t;
module top;
  class H; s_t hs; endclass
  class C;
    s_t cs;
    H h;
    function void g(int j);
      cs.f[j]++;
      h.hs.f[j]--;
    endfunction
  endclass
endmodule
