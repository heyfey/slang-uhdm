// § impStructRefOpAtRef252
package p0;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t A = '{a : 1, b : 2, c : 3};
endpackage
package p;
  import p0::*;
  localparam s_t B = p0::A;
  localparam s_t C = A;
endpackage
module top import p::*; #(parameter Q = 1) (output logic [31:0] o);
  assign o = B.a + C.b;
endmodule
