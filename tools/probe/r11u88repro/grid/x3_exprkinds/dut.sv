// r11u85 x3 -- LAW C: WHICH element forms lose the decompile in the interface
// home.  Six overrides of one interface, one form each: a literal, a bare
// localparam NAME, an arithmetic op, a size cast, a concatenation, and a
// unary minus.
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
endpackage

interface ifc #(parameter pk::s_t C = '{n: 8'd3, m: 8'd4}) ();
  logic [31:0] y;
  assign y = C.n;
endinterface

module dut (output logic [31:0] o);
  localparam int K = 2;
  localparam logic [7:0] KB = 8'd6;
  ifc #(.C('{n: 8'd7,        m: 8'd0})) u_lit ();
  ifc #(.C('{n: 8'(K),       m: 8'd0})) u_nam ();
  ifc #(.C('{n: 8'(K + 3),   m: 8'd0})) u_add ();
  ifc #(.C('{n: 8'(9),       m: 8'd0})) u_cst ();
  ifc #(.C('{n: {4'h1, 4'h2}, m: 8'd0})) u_cat ();
  ifc #(.C('{n: 8'(-K),      m: 8'd0})) u_neg ();
  ifc #(.C('{n: KB,          m: 8'd0})) u_bare ();
  ifc #(.C('{n: KB + 8'd1,   m: 8'd0})) u_op ();
  ifc #(.C('{n: -KB,         m: 8'd0})) u_un ();
  ifc #(.C('{n: KB > 8'd2 ? 8'd3 : 8'd4, m: 8'd0})) u_tern ();
  assign o = u_lit.y ^ u_nam.y ^ u_add.y ^ u_cst.y ^ u_cat.y ^ u_neg.y ^
             u_bare.y ^ u_op.y ^ u_un.y ^ u_tern.y;
endmodule
