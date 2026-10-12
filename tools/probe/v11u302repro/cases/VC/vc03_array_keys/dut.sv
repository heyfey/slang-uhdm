// § castPatTagKeyLocThroughParens302
// vc03: a cast-wrapped pattern on a packed array keyed by index, beside a struct one
package p;
  typedef logic [3:0][7:0] arr_t;
  typedef struct packed { int unsigned n; logic [15:0] h; } cfg_t;
  localparam arr_t A = arr_t'('{0: 8'd1, 1: 8'd2, default: 8'd0});
  localparam cfg_t C = cfg_t'('{n: 2, h: 16'h4});
endpackage
module dut (output logic [31:0] o);
  assign o = p::A + p::C.n;
endmodule
