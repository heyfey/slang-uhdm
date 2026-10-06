// § impPatMemberReadParentsAll252
package p;
  typedef enum { E0, E1, E2 } e_t;
  typedef struct packed { integer a; integer b; integer c; } s_t;
  localparam s_t D = '{a : 1, b : 2 + 1, c : (1 << E2)};
  localparam s_t U = D;
  localparam integer X = U.a;
endpackage
module leaf import p::*; #(parameter Q = 1) (output logic [31:0] o);
  assign o = D.b + Q;
endmodule
module mid #(parameter Q = 1) (output logic [31:0] o);
  if (Q > 0) begin : g
    leaf #(Q) l(o);
  end
endmodule
module top(output logic [31:0] o);
  mid #(2) m(o);
endmodule
