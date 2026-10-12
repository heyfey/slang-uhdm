// § modFnLitLeftoverAtLiteral302
// l02: sized hex / decimal / binary literals in a module builder
package pk;
  typedef struct packed { logic [63:0] a; logic [7:0] b; logic [3:0] c; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk();
    pk::c_t c; c.a = 64'h1000; c.b = 8'd5; c.c = 4'b1010; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam logic [7:0] LB = L.b;
  assign o = 1'b0;
endmodule
