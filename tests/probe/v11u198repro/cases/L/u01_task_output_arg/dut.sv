// § lvIdxCallArgIsRead198
module top (input logic clk, input logic [1:0] k, input logic [2:0] q [4], output logic [7:0] o, output logic [7:0] o2);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  s_t s, t;
  logic [7:0] arr, arr2;
  logic [7:0] a2 [8];
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  task automatic tt(output logic [2:0] ov); ov = 3'd1; endtask
  always @(posedge clk) begin
    tt(s.f[k]);
    arr[fx(q[k])] <= 1'b1;
  end
  assign o = arr;
  assign o2 = arr2;
endmodule
