// § pkgArrTdElemClone209
package q;
  typedef union packed {
    logic [1:0] y;
    logic [1:0] z;
  } u_t;
  typedef u_t [3:0] v_t;
endpackage
module top(output [1:0] o);
  q::v_t w;
  assign w[2].y = 2'b01;
  assign o = w[2].z;
endmodule
