// § hpLvSelIdxNamesByPath224
module top(input logic [1:0] d, output logic [32:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  typedef struct packed { logic [1:0] k; logic [1:0] m; } t_t;
  s_t s; t_t t;
  assign t = 4'b0110;
  always_comb begin
    s = '0;
    s.arr[t.k][1:0] = d;
  end
  assign o = s;
endmodule
