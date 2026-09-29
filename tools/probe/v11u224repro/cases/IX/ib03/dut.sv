// § ipsBasePfxScopeJoin224
interface ifc;
  typedef struct { logic [7:0] v; } s_t;
  s_t arr[4];
  function automatic logic [1:0] f(int i, int k);
    return arr[i].v[k-:2];
  endfunction
endinterface
module top(output logic [1:0] o);
  ifc u();
  assign o = u.f(1, 5);
endmodule
