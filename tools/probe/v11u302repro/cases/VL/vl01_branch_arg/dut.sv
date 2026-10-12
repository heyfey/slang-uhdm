// § modFnLitLeftoverValueGate302v
// vl01: the builder writes b in both branches of an if on its argument; the taken branch's literal is not the last one written
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk(input bit s);
    pk::c_t c; c.a = 5; if (s) c.b = 64; else c.b = 99; return c;
  endfunction
  localparam pk::c_t L = mk(1'b1);
  localparam int unsigned LB = L.b;
  assign o = 1'b0;
endmodule
