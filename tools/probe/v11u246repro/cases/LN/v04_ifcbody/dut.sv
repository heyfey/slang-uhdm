// § contLvMidSelNetBase246
package hp;
  typedef struct packed { logic [7:0] d; } key_t;
  typedef struct packed { key_t [1:0] key; logic v; } s_t;
endpackage
interface ifc;
  import hp::*;
  wire s_t w;
  assign w.key[1].d = 8'h11;
  assign w.key[0].d = 8'h22;
  assign w.v = 1'b0;
  assign impl_a = w.v;
  modport mp(input w);
endinterface
module top(output logic [7:0] o);
  ifc i0();
  assign o = i0.w.key[1].d;
endmodule
