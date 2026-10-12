// § modFnLitLeftoverAtLiteral302
// vl03: a literal wider than its member (truncated on write) and a sized binary literal
package pk;
  typedef struct packed { logic [7:0] a; logic [3:0] b; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 300; c.b = 4'b1010; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam int unsigned LA = L.a;
  assign o = 1'b0;
endmodule
