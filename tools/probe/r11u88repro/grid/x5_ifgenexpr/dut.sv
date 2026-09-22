// r11u85 x5 -- LAW C in the interface's OTHER home: the same expression-valued
// override element read from the interface BODY and from a gen scope INSIDE
// the interface.  `emitGenScopes` is a home an interface reaches, and its
// width walk answers 0 there, so it carries the same raw-operand reading.
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
endpackage

interface ifc #(parameter pk::s_t C = '{n: 8'd3, m: 8'd4}) ();
  logic [31:0] body_y;
  assign body_y = C.n;
  if (1) begin : gi
    logic [31:0] gen_y;
    assign gen_y = C.n;
  end
endinterface

module dut (output logic [31:0] o);
  localparam int K = 1;
  ifc #(.C('{n: 8'(K + 1), m: 8'd5})) u_e ();
  assign o = u_e.body_y ^ u_e.gi.gen_y;
endmodule
