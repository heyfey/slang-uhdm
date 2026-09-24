// v16 — a STRUCT-typed member whose pattern ELEMENT is a plain integral
// literal.  Together with v10 this separates "the member TYPE is a struct"
// from "the element VALUE is itself a pattern or a reference".
package pk;
  typedef struct packed { int unsigned x; int unsigned y; } n_t;
  typedef struct packed { n_t a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 64'd5, b: 3};
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
