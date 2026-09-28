// § pkgArrTdElemClone209
package q;
  typedef struct packed {
    logic a;
    logic b;
  } i_t;
  typedef struct packed {
    i_t y;
    logic z;
  } s_t;
  typedef s_t [1:0][3:0] v_t;
endpackage
module top(output o);
  q::v_t w;
  assign w[1][2].y.a = 1;
  assign o = w[1][2].y.b;
endmodule
