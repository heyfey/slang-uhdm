// § pkgArrTdElemClone209 — r11u217 h01: one package packed-array typedef of a struct used in TWO modules (member writes and reads through elements)
package q;
  typedef struct packed { logic y; logic [2:0] z; } s_t;
  typedef s_t [3:0] v_t;
endpackage
module a (output logic o);
  q::v_t w;
  assign w[2].y = 1'b1;
  assign w[2].z = 3'd2;
  assign {w[3], w[1], w[0]} = '0;
  assign o = w[2].y;
endmodule
module top (output logic o, output logic [2:0] p);
  q::v_t w;
  assign w[0].z = 3'd5;
  assign w[0].y = 1'b0;
  assign w[3:1] = '0;
  assign p = w[0].z;
  a u (.o(o));
endmodule
