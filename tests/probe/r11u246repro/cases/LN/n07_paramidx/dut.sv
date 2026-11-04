// § contLvMidSelNetBase246
package hp;
  typedef struct packed { logic [31:0] d; } key_t;
  typedef struct packed { key_t [7:0] key; logic v; } s_t;
endpackage
module m import hp::*; #(parameter int K = 2) (output logic o);
  wire s_t w;
  localparam int L = 3;
  assign w.key[K].d = '1;
  assign w.key[L-1].d = '0;
  assign w.key[$clog2(8)].d = '0;
  assign o = w.v;
endmodule
module top;
  logic o;
  m #(.K(4)) u(.o(o));
endmodule
