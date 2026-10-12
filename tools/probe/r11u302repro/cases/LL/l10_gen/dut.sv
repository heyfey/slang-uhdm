// § modFnLitLeftoverAtLiteral302
// l10: the call in a generate-block localparam, depth 2 instance
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module mid(output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 1; c.b = 12; return c;
  endfunction
  if (1) begin : g
    localparam pk::c_t L = mk();
    localparam int unsigned S = L.b;
  end
  assign o = 1'b0;
endmodule
module dut(output logic o);
  mid m (.o(o));
endmodule
