// r11u85 x2 -- the MODULE twin of x1: the same override, the same two
// elements, in a MODULE.  The attribution control for the decompile.
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
endpackage

module sub #(parameter pk::s_t C = '{n: 8'd3, m: 8'd4}) (output logic [31:0] y,
                                                         output logic [31:0] z);
  assign y = C.n;
  assign z = C.m;
endmodule

module dut (output logic [31:0] o);
  localparam int K = 1;
  logic [31:0] ey, ez, dy, dz;
  sub #(.C('{n: 8'(K + 1), m: 8'd5})) u_e (.y(ey), .z(ez));
  sub u_d (.y(dy), .z(dz));
  assign o = ey ^ ez ^ dy ^ dz;
endmodule
