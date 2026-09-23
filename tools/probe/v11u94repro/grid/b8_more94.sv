// v11u94 break arms: typed override patterns, static lifetime, parenthesized patterns
package p98;
  typedef struct packed { logic [7:0] a; logic [3:0] b; } h_t;
endpackage
module b8c #(parameter int W = 4, parameter p98::h_t HP = '{a: 1, b: 2}) (input logic i, output logic o);
  typedef struct packed { logic [W-1:0] x; logic [W*2-1:0] y; } ct_t;
  localparam ct_t PN = '{x: 1, y: 2};
  assign o = i ^ HP.a[0] ^ PN.x[0];
endmodule
module b8 #(parameter int D = 4) (input logic clk, input logic i, output logic o1, output logic o2, output logic [7:0] q);
  typedef logic [7:0] a01_t [D];
  static a01_t v01_static;
  a01_t v02_plain;
  b8c #(.W(6), .HP(p98::h_t'{default: 5})) u_a (.i(i), .o(o1));
  b8c #(.W(3), .HP('{default: 3})) u_b (.i(i), .o(o2));
  always_ff @(posedge clk) begin v01_static[0] <= 1; v02_plain[0] <= 1; q <= v01_static[1] ^ v02_plain[1]; end
endmodule
