// § callArgInSelIdxChainName201
module n03 (input logic [1:0] k, input logic [3:0][2:0] v, output logic [7:0] o, output logic [3:0][2:0] q);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  typedef struct packed { s_t g; } t_t;
  t_t s, t;
  logic [7:0] arr;
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  assign s.g.f = v;
  always_comb begin
    arr = '0;
    arr[fx(s.g.f[k])] = 1'b1;
    t = '0;
    t.g.f[fx(s.g.f[k + 1])] = 3'd2;
    t.g.f[fx(s.g.f[k])] += 3'd1;
    q = t.g.f;
  end
  task automatic tk(inout logic [7:0] a);
    a[fx(s.g.f[k])] ^= 1'b1;
  endtask
  assign o = arr;
endmodule
