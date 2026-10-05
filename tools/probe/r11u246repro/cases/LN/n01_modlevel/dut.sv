// § contLvMidSelNetBase246
package hp;
  typedef struct packed { logic [31:0] d; } key_t;
  typedef struct packed { key_t [7:0] key; logic v; } s_t;
endpackage
module m import hp::*; (output logic o);
  wire s_t w;
  assign w.key[1].d = '1;
  assign w.key[2+1].d = '0;
  assign o = w.v;
endmodule
module top;
  logic o;
  m u(.o(o));
endmodule
