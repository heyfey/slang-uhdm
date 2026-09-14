// v11 — THREE members, the LAST of them a nested pattern literal.  If the
// nested ELEMENT is the distinguisher, one nested element anywhere is enough.
package pk;
  typedef struct packed { int unsigned x; int unsigned y; } n_t;
  typedef struct packed { int unsigned p; n_t q; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{p: 5, q: '{x: 1, y: 2}};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
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
