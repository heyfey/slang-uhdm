// § modFnLitLeftoverAtLiteral302
// l14: unbased and signed-cast literals beside a plain one
package pk;
  typedef struct packed { logic [7:0] a; logic [7:0] b; int unsigned c; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = '1; c.b = 'd3; c.c = unsigned'(7); return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam logic [7:0] LA = L.a;
  assign o = 1'b0;
endmodule
