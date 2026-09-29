// § hpLvSelIdxNamesByPath224
module top(input logic clk, input logic [1:0] i, input logic [1:0] d, output logic [32:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  always_ff @(posedge clk) begin
    s.arr[i][1:0] += d;
    s.arr[i][3:2]++;
  end
  assign o = s;
endmodule
