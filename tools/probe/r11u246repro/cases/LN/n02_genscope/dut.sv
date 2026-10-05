// § contLvMidSelNetBase246
package hp;
  typedef struct packed { logic [31:0] d; } key_t;
  typedef struct packed { key_t [7:0] key; logic v; } s_t;
endpackage
module m import hp::*; (output logic o);
  wire s_t w;
  for (genvar i = 0; i < 2; i++) begin : g
    assign w.key[7-i].d = '0;
    assign w.key[i].d = '1;
  end
  assign o = w.v;
endmodule
module top;
  logic o;
  m u(.o(o));
endmodule
