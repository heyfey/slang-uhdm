// § hpLvSelIdxNamesByPath224
module top(input logic [1:0] i, input logic [1:0] d, output logic [32:0] o);
  typedef struct packed { logic [7:0] b; } e_t;
  typedef struct packed { e_t [3:0] a; logic v; } s_t;
  s_t s;
  always_comb begin
    s = '0;
    s.a[i].b[1:0] = d;
  end
  assign o = s;
endmodule
