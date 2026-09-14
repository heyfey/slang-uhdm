// t3 — the base struct parameter OVERRIDDEN, and the read one instance down.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
  function automatic c_t mk(int unsigned x);
    c_t c; c.a = x; c.b = 32; return c;
  endfunction
  localparam c_t C = mk(3);
  localparam c_t D = mk(9);
endpackage

module leaf #(
    parameter pk::c_t K = pk::C
) (output logic o);
  localparam int LA = K.a;
  localparam int LB = K.b + 1;
  assign o = ^{LA[0], LB[0]};
endmodule

module dut(output logic o1, output logic o2);
  leaf u0 (.o(o1));                 // NOT overridden
  leaf #(.K(pk::D)) u1 (.o(o2));    // OVERRIDDEN with the other package value
endmodule
