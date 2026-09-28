// § pkgArrTdElemClone209
package q;
  typedef struct packed {
    logic y;
    logic z;
  } s_t;
  typedef s_t [3:0] v_t;
endpackage
module top(output o, output p);
  q::v_t w;
  q::s_t u;
  assign w[2].y = 1;
  assign u.z = 0;
  assign o = w[2].y;
  assign p = u.z;
endmodule
