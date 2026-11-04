// § hpLvSelIdxNamesByPath224
logic [1:0] gk = 2'd3;
module top(input logic [1:0] d, output logic [32:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  always_comb begin
    s = '0;
    s.arr[gk][1:0] = d;
  end
  assign o = s;
endmodule
