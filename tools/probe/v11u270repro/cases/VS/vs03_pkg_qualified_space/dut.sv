// § scopedCallPrefixEndsAtColons270
package pk;
  parameter int W = 8;
  parameter logic [7:0] V = 8'hA5;
  function automatic int fn(int a); return a + 1; endfunction
  typedef struct packed { logic [3:0] a, b; } s_t;
  parameter s_t S = '{a: 1, b: 2};
endpackage
module top (output logic [7:0] o, output logic [3:0] q, output int r);
  logic [pk:: W-1:0] v;
  assign o = pk:: V;
  assign q = pk:: V[3:0] ^ pk::
     V[7:4];
  assign r = pk:: fn(3) + pk::S.a;
  initial v = pk:: S.b;
endmodule
