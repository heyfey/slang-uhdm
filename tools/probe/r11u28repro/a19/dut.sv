// a19 — THE DIVISIBILITY BAIL WITH A MODULE HOLDER.  § modStructFuncAssembleBin
// already leaves the `struct_var` in place when its own bail fires; this arm
// asks whether the WIDTH bail reaches it too.  95-bit member, 2 operands.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { logic [94:0] u; int unsigned d; } c_t;
endpackage

module dut(output logic o);
  localparam pk::in_t UU = '{a: 11, b: 22};
  function automatic pk::c_t mk();
    pk::c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam pk::c_t L = mk();
  localparam logic [94:0] MS = L.u;
  kid #(.CFG(L)) k0 (.o(o));
endmodule

module kid #(
    parameter pk::c_t CFG = '{u: 95'd0, d: 32'd0}
) (output logic o);
  localparam logic [94:0] S = CFG.u;
  assign o = 1'b0;
endmodule
