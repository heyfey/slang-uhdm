// § lvIdxCallArgIsRead198
module top (input logic clk, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  s_t s;
  logic [7:0] arr;
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  always @(posedge clk) begin
    arr[fx(`ARGSEL(s, k))] <= 1'b1;
    `LVIDX(arr, s, 0) <= 1'b0;
  end
  assign o = arr;
endmodule
