// v17 — a packed-UNION member whose pattern ELEMENT is itself a pattern.
package pk;
  typedef struct packed { int unsigned w; } un_t;
  typedef union packed { int unsigned w; logic [31:0] v; } uu_t;
  typedef struct packed { uu_t a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam uu_t UA = 32'd1;
  localparam in_t UU = '{a: UA, b: 3};
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
