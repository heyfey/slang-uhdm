// § lvIdxCallArgIsRead198
module top (input logic clk, input logic [1:0] k, input logic [2:0] q [4], output logic [7:0] o, output logic [7:0] o2);
  typedef struct packed { logic [3:0][2:0] f; } s_t;
  s_t s, t;
  logic [7:0] arr, arr2;
  logic [7:0] a2 [8];
  function automatic logic [2:0] fx(input logic [2:0] x); return x; endfunction
  function automatic logic [7:0] fz(input s_t sv);
    logic [7:0] rr;
    rr = '0;
    for (int j = 0; j < 4; j++) rr[fx(sv.f[j])] = 1'b1;
    return rr;
  endfunction
  always_comb arr = fz(s);
  assign o = arr;
  assign o2 = arr2;
endmodule
