// § modFnLitLeftoverAtLiteral302
// vl05: a module builder called from a localparam inside an if-generate block and a two-level for-generate
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module dut #(parameter bit EN = 1) (output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 6; c.b = 60; return c;
  endfunction
  if (EN) begin : g
    localparam pk::c_t L = mk();
    localparam int unsigned LA = L.a;
  end
  for (genvar i = 0; i < 2; i++) begin : f
    for (genvar j = 0; j < 1; j++) begin : h
      localparam pk::c_t M = mk();
    end
  end
  assign o = 1'b0;
endmodule
