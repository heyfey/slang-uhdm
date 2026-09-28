// § pkgArrTdElemClone209
typedef struct packed {
  logic y;
  logic z;
} s_t;
typedef s_t [3:0] v_t;
module top(output o);
  v_t w;
  assign w[2].y = 1;
  assign o = w[2].y;
endmodule
