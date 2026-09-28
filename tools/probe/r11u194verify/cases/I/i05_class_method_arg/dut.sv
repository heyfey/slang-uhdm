// § incDecMemberSelIsLvalue184: inc/dec member-select operands in a class method whose index is a method call taking a member select, and a handle's method call
package pk;
  typedef struct packed { logic [3:0][7:0] f; logic [3:0][1:0] g; } s_t;
  class c;
    s_t s;
    c o;
    function logic [1:0] pick(logic [1:0] x); return x; endfunction
    function void tick(logic [1:0] k);
      s.f[pick(s.g[k])]++;
      s.f[o.pick(s.g[k])]--;
    endfunction
  endclass
endpackage
module top; endmodule
