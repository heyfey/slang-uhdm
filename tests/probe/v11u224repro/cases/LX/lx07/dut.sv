// § hpLvSelIdxNamesByPath224
module top(input logic [1:0] i, input logic [1:0] j, input logic [1:0] d, output logic [64:0] o);
  typedef struct packed { logic [1:0][3:0][7:0] arr; logic v; } s_t;
  s_t s;
  always_comb begin
    s = '0;
    s.arr[j][i+1][1:0] = d;
    s.arr[~j][i][3:2] = d;
  end
  assign o = s;
endmodule
