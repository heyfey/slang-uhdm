// § hpLvSelIdxNamesByPath224
module top(input logic [1:0] d, output logic [32:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  assign w = d[0];
  always_comb begin
    s = '0;
    s.arr[w][1:0] = d;
  end
  assign o = s;
endmodule
