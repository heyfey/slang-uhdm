// § modFnLitLeftoverAtLiteral302
// l08: the folded members are used as constant slots (bounds, widths, counts)
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module dut(input logic [15:0] i, output logic [7:0] o, output logic [3:0] p);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 8; c.b = 2; return c;
  endfunction
  localparam pk::c_t L = mk();
  logic [L.a-1:0] w;
  assign w = i[L.a-1:0];
  assign o = {L.b{w[3:0]}};
  assign p = i[L.b +: 4];
endmodule
