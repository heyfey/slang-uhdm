// r11u85 x1 -- LAW C: an EXPRESSION-valued override element in an interface's
// parameter, with NO genvar anywhere -- is the missing `vpiDecompile` a
// property of the ELEMENT's form or of the generate loop?  The same override
// carries a LITERAL element beside it, and a DEFAULT-valued instance is the
// in-arm control.
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
endpackage

interface ifc #(parameter pk::s_t C = '{n: 8'd3, m: 8'd4}) ();
  logic [31:0] y;
  logic [31:0] z;
  assign y = C.n;
  assign z = C.m;
endinterface

module dut (output logic [31:0] o);
  localparam int K = 1;
  ifc #(.C('{n: 8'(K + 1), m: 8'd5})) u_e ();
  ifc u_d ();
  assign o = u_e.y ^ u_e.z ^ u_d.y ^ u_d.z;
endmodule
