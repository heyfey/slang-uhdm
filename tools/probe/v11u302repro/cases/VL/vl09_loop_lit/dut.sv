// § modFnLitLeftoverAtLiteral302
// vl09: the literal write sits inside a for loop and a begin block
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 1;
    for (int i = 0; i < 2; i++) begin c.b = 33; end
    return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam int unsigned LB = L.b;
  assign o = 1'b0;
endmodule
