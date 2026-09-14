// m16 — A CONCAT-VALUED PARAMETER READ WHOLE, ALONE.  `getValue("CAT")` hands
// the concat operation back and `reduceExpr` REDUCES it, so golden's leftover
// is a BIN CONSTANT (the operand bits, `3` then `4` at 32 bits each, size 64)
// and the assembly proceeds normally.  This law declines the shape outright —
// `memLeftPatParamClone26` takes ONLY `vpiAssignmentPatternOp` — so this arm
// must be byte-identical on the two binaries.  Its head is the concat
// leftover's own encoding, this pass's R4.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  localparam in_t CAT = {32'd3, 32'd4};
  typedef struct packed { in_t c; int unsigned y; } k_t;
  function automatic k_t mk();
    k_t x; x.c = CAT; x.y = 9; return x;
  endfunction
  localparam k_t K = mk();
endpackage

module kid #(
    parameter pk::k_t P = pk::K
) (output logic o);
  localparam pk::in_t RC = P.c;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
