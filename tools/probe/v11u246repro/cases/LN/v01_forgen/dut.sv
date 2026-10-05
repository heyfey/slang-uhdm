// § contLvMidSelNetBase246
package hp;
  typedef struct packed { logic [7:0] d; } key_t;
  typedef struct packed { key_t [3:0] key; logic v; } s_t;
endpackage
module m import hp::*; (output logic [7:0] o);
  wire s_t w;
  for (genvar i = 0; i < 4; i++) begin : g
    assign w.key[3 - i].d = 8'(i);
  end
  assign w.v = 1'b0;
  assign o = w.key[0].d;
endmodule
module top(output logic [7:0] o);
  m u(.o(o));
endmodule
