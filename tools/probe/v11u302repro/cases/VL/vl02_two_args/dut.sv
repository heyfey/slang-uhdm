// § leftoverSlotSoleWriter302v
// vl02: one builder called twice with different arguments, each picking a different literal
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk(input bit s);
    pk::c_t c; c.a = 5; if (s) c.b = 64; else c.b = 99; return c;
  endfunction
  localparam pk::c_t L0 = mk(1'b0);
  localparam pk::c_t L1 = mk(1'b1);
  localparam int unsigned LB = L0.b + L1.b;
  assign o = 1'b0;
endmodule
