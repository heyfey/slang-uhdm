// § lvIdxCallArgIsRead198
module top (input logic clk, input logic [1:0] k, input logic [2:0] q [4], output logic [7:0] o, output logic [7:0] o2);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  s_t s, t;
  logic [7:0] arr, arr2;
  logic [7:0] a2 [8];
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  function automatic logic [2:0] fo(output logic [2:0] ov); ov = 3'd2; return 3'd1; endfunction
  logic [2:0] r;
  always_comb begin
    r = fo(t.f[k]);
    arr2 = '0;
    arr2[fo(s.f[k])] = 1'b1;
  end
  assign o = arr;
  assign o2 = arr2;
endmodule
