// § contLvMidSelNetBase246
package hp;
  typedef struct packed { logic [7:0] d; logic [1:0] e; } key_t;
  typedef struct packed { key_t [3:0] key; logic v; } s_t;
  function automatic int idx(int a); return a + 1; endfunction
endpackage
module m import hp::*; (output s_t o);
  localparam int LP = 1;
  assign o.key[idx(0)].d = 8'hAA;
  assign o.key[~LP & 3].e = 2'b01;
  assign o.key[LP - 1].d[3:0] = 4'h5;
  assign o.key[$clog2(8)].d = 8'h1;
  assign o.key[3].e = '0;
  assign o.key[0].e = '0;
  assign o.key[LP - 1].d[7:4] = '0;
  assign o.key[2].d = '0;
  assign o.v = 1'b1;
endmodule
module top(output hp::s_t o);
  m u(.o(o));
endmodule
