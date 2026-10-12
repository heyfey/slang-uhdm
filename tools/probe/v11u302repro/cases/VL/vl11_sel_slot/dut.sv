// § modFnLitLeftoverAtLiteral302
// vl11: the builder's result read in constant slots (part-select bounds, replication count, indexed width, dimension)
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module dut(input logic [31:0] i, output logic [31:0] o);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 7; c.b = 3; return c;
  endfunction
  localparam pk::c_t L = mk();
  logic [L.a:0] w;
  assign w = {L.b{1'b1}};
  assign o = {i[L.a:L.b], i[L.b +: 4], w};
endmodule
