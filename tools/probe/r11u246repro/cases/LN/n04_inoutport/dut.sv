// § contLvMidSelNetBase246
package hp;
  typedef struct packed { logic [31:0] d; } key_t;
  typedef struct packed { key_t [7:0] key; logic v; } s_t;
endpackage
module m import hp::*; (inout wire s_t io, output logic o);
  assign io.key[0].d = 'z;
  assign o = io.v;
endmodule
module top;
  wire hp::s_t io;
  logic o;
  m u(.io(io), .o(o));
endmodule
