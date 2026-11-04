// § modFnLitLeftoverAtLiteral302
// l01: module-held builder, plain literals on two members
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 5; c.b = 64; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam int unsigned LA = L.a;
  assign o = 1'b0;
endmodule
