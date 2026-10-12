// § modFnLitLeftoverAtLiteral302
// vl06: a child module with the builder instantiated twice with different overrides of an argument parameter
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module kid #(parameter int unsigned W = 1) (output logic o);
  function automatic pk::c_t mk(input int unsigned w);
    pk::c_t c; c.a = w; c.b = 64; return c;
  endfunction
  localparam pk::c_t L = mk(W);
  localparam int unsigned LB = L.b;
  assign o = L.a[0];
endmodule
module dut(output logic o1, o2);
  kid #(.W(3)) u1 (.o(o1));
  kid #(.W(4)) u2 (.o(o2));
endmodule
