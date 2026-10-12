// § modFnLitLeftoverAtLiteral302
// vl13: the builder's localparam read in a for-generate and by an interface port's module, two builders sharing a literal value
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
interface ifc;
  logic [3:0] s;
endinterface
module kid (ifc p, output logic [3:0] o);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 2; c.b = 2; return c;
  endfunction
  localparam pk::c_t L = mk();
  for (genvar i = 0; i < L.a; i++) begin : g
    assign o[i] = p.s[i + L.b];
  end
  assign o[3:2] = '0;
endmodule
module dut(output logic [3:0] o);
  ifc i0 ();
  assign i0.s = 4'h5;
  kid u (.p(i0), .o(o));
endmodule
