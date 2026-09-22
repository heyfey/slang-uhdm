// v11u83 b13 -- the MODULE twin of b6's cell: a struct-parameter member whose
// override element is an EXPRESSION.  Does the module home's fold carry a
// vpiDecompile golden omits, or is the extra field the interface home's?
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
endpackage

module sub #(parameter pk::s_t C = '{n: 8'd3, m: 8'd4}) (output logic [31:0] y);
  assign y = C.n;
endmodule

module dut (output logic [31:0] o);
  for (genvar i = 0; i < 2; i++) begin : gl
    sub #(.C('{n: 8'(i + 1), m: 8'd5})) u_s (.y());
  end
  assign o = 32'd0;
endmodule
