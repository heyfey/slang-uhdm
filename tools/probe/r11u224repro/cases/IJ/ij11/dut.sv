// § ipsBasePfxScopeJoin224
module top(input int i, input int k, output logic [1:0] o);
  typedef struct { logic [7:0] v; } s_t;
  s_t arr[4];
  for (genvar g = 0; g < 2; g++) begin : gb
    wire [1:0] w = arr[i].v[k+:2];
  end
  assign o = gb[0].w;
endmodule
