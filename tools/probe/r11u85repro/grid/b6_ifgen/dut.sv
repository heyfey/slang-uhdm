// v11u83 b6 -- LAW A x LAW B: an interface instantiated inside a GENERATE
// loop, importing a package AND folding a struct-param member at body level.
// Two elaborated views of one def; both laws fire in both.
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
  logic [7:0] gv;
  wire  [7:0] gn;
endpackage

interface ifc #(parameter pk::s_t C = '{n: 8'd3, m: 8'd4}) ();
  import pk::*;
  logic [31:0] y;
  assign y = C.n;
  if (1) begin : gi
    logic [31:0] gv; assign gv = 32'd11;
    logic [31:0] gn; assign gn = 32'd12;
  end
endinterface

module dut (output logic [31:0] o);
  for (genvar i = 0; i < 2; i++) begin : gl
    ifc #(.C('{n: 8'(i + 1), m: 8'd5})) u_if ();
  end
  assign o = gl[0].u_if.y ^ gl[1].u_if.y;
endmodule
