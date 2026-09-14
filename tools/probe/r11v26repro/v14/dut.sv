// v14 — a PACKED-ARRAY member inside the read parameter's struct.  Is golden's
// refusal to flatten about a STRUCT member specifically, or about any
// aggregate member?
package pk;
  typedef struct packed { logic [1:0][31:0] a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: '{32'd1, 32'd2}, b: 3};
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
