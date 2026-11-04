// § contLvMidSelNetBase246
package hp;
  typedef struct packed { logic [31:0] d; } key_t;
  typedef struct packed { key_t [7:0] key; logic v; } s_t;
endpackage
module m import hp::*; (output logic [31:0] o);
  wire s_t w;
  assign w.key[1] = '0;
  assign o = w.key[1].d;
endmodule
module top;
  logic [31:0] o;
  m u(.o(o));
endmodule
