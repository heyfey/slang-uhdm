// v13 — A REPLICATION-valued element inside the pattern, read whole.
package pk;
  typedef struct packed { logic [31:0] a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: {2{16'd1}}, b: 22};
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
