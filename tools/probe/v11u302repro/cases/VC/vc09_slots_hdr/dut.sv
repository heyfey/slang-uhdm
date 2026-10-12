// § castPatTagKeyLocThroughParens302
// vc09: cast-wrapped patterns as a header parameter default, an override on an instance, and read in constant slots
package p;
  typedef struct packed { int unsigned n; int unsigned h; } cfg_t;
endpackage
module kid #(parameter p::cfg_t C = p::cfg_t'('{n: 7, h: 2})) (input logic [31:0] i, output logic [31:0] o);
  logic [C.n:0] w;
  assign w = {C.h{1'b1}};
  assign o = {i[C.n:C.h], i[C.h +: 4], w};
endmodule
module dut (input logic [31:0] i, output logic [31:0] o1, o2);
  kid u1 (.i(i), .o(o1));
  kid #(.C(p::cfg_t'('{n: 9, h: 3}))) u2 (.i(i), .o(o2));
endmodule
