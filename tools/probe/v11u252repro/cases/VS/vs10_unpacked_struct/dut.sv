// § impPatMemberReadParentsAll252
package p;
  typedef struct { integer a; integer b; } u_t;
  localparam u_t D = '{a : 1, b : 2};
  localparam integer X = D.a;
endpackage
module top import p::*; #(parameter Q = 1) (output logic [31:0] o);
  assign o = X + D.b;
endmodule
