// r11u85 x4 -- LAW B x LAW C in one cell: a NESTED member whose override
// element is an EXPRESSION, in the interface home and in the module home.
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  typedef struct packed { cfg_t inner; logic [3:0] t; } outer_t;
endpackage

interface ifc #(parameter p::outer_t D = '{inner: '{n: 1, m: 8'h0}, t: 4'h0}) ();
  logic [31:0] y;
  assign y = D.inner.n;
endinterface

module sub #(parameter p::outer_t D = '{inner: '{n: 1, m: 8'h0}, t: 4'h0})
            (output logic [31:0] y);
  assign y = D.inner.n;
endmodule

module dut (output logic [31:0] o);
  localparam int K = 4;
  logic [31:0] my;
  ifc #(.D('{inner: '{n: 32'(K + 1), m: 8'h0}, t: 4'h0})) u_i ();
  sub #(.D('{inner: '{n: 32'(K + 1), m: 8'h0}, t: 4'h0})) u_m (.y(my));
  assign o = u_i.y ^ my;
endmodule
