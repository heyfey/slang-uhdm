// § hpLvSelIdxNamesByPath224
module top(input logic [1:0] i, input logic [1:0] d, output logic [32:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } in_t;
  typedef struct packed { in_t t; logic w; } s_t;
  s_t s;
  always_comb begin
    s = '0;
    s.t.arr[i][1:0] = d;
  end
  assign o = s;
endmodule
