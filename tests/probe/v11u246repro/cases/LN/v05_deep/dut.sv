// § contLvMidSelNetBase246
package hp;
  typedef struct packed { logic [3:0] c; } in_t;
  typedef struct packed { in_t [1:0] b; } mid_t;
  typedef struct packed { mid_t [1:0] a; } s_t;
endpackage
module m import hp::*; (output logic [3:0] o);
  tri s_t w;
  assign w.a[1].b[0].c = 4'h1;
  assign w.a[1].b[1].c = 4'h2;
  assign w.a[0].b[0] = '0;
  assign w.a[0].b[1].c = 4'h3;
  assign o = w.a[1].b[0].c;
endmodule
module top(output logic [3:0] o);
  m u(.o(o));
endmodule
