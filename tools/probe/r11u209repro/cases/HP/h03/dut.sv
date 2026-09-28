// § pkgArrTdElemClone209
package q;
  typedef struct packed {
    logic y;
    logic z;
  } s_t;
endpackage
module top(output o);
  typedef q::s_t [3:0] v_t;
  v_t w;
  assign w[2].y = 1;
  assign o = w[2].y;
endmodule
