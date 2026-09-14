// v6 — A BUILDER THE RECOGNIZER REJECTS.  The body carries an `if`, which is
// outside the modelled subset, so `srlgEvalFuncMemberLeftovers` fails and
// `paramRead` is never recorded: no clone, no flatten trigger, no bail
// exception.  The PRODUCER still evaluates the function and still looks `UU`
// up by name.  This arm must be BYTE-IDENTICAL on the two binaries, and it
// says how big the gap left behind is.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c;
    c.u = UU;
    if (1) c.d = 64; else c.d = 0;
    return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::in_t S = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
