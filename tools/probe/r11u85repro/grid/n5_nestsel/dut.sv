// r11u85 n5 -- IS THE WIDTH ANSWER THE INTERFACE HOME'S, OR EVERY HOME WHERE
// `adjustSize` DOES NOT RUN?  A MODULE body reading the same nested member
// onto a SELECT Lhs: `writeCont_assign` fills `tps` from a whole-name Lhs
// only, so `adjustSize` returns at once here exactly as it does in an
// interface.  Golden's answer decides whether the law is home-independent.
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  typedef struct packed { cfg_t inner; logic [3:0] t; } outer_t;
  localparam outer_t OUT = '{inner: '{n: 11, m: 8'h5A}, t: 4'h3};
endpackage

module sub #(parameter p::outer_t D = p::OUT) (output logic [31:0] o);
  logic [31:0] whole;
  logic [31:0] sel;
  logic [31:0] arr [0:1];
  assign whole  = D.inner.n;
  assign sel[0] = D.inner.n;
  assign arr[1] = D.inner.n;
  assign o = whole ^ {31'd0, sel[0]} ^ arr[1];
endmodule

module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
