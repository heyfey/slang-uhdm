// m14 — THE NEGATIVE CONTROL FOR THE FLATTEN TRIGGER.  The very body of m1,
// in a function NO parameter ever calls: nothing evaluates it during
// elaboration, `getValue("UU")` is never reached, and golden must keep UU's
// tagged_pattern tree.  A rule that fired off the SYNTAX of the body would
// flatten here and be wrong.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
endpackage

module dut(output logic o);
  assign o = 1'b0;
endmodule
