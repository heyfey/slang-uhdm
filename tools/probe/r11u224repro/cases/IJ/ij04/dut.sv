// § ipsBasePfxScopeJoin224
module top(input int i, input int k, output logic [1:0] o);
  typedef struct { logic [7:0] v; } s_t;
  s_t arr[4];
  function automatic logic [1:0] f(int i, int k);
    return arr[i].v[k+:2];
  endfunction
  assign o = f(i, k);
endmodule
