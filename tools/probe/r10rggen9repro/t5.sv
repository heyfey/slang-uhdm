// r10rggen9 t5: how is a localparam's CONST-FUNCTION-CALL fold ENCODED?
// Rggen's rggen_address_decoder:18
//   localparam bit [WIDTH-LSB-1:0] END_ADDRESS = calc_end_address(...);
// comes out of Surelog BIN at the param width (6'b010100) while our emitter
// writes decimal UINT:20.  The sibling localparams on line 16/17 (a $clog2
// fold and a PART-SELECT fold) are already byte-identical, so the question is
// whether the BIN encoding is a property of (a) the DECLARED bit[] type, or
// (b) the shape of the function's RETURN expression.  One localparam per
// candidate; every one is read by a generate condition so it must fold.
module top #(
  parameter int             WIDTH         = 8,
  parameter bit [7:0]       START_ADDRESS = 8'h14,
  parameter int             BYTE_SIZE     = 4
)(
  output logic o
);
  localparam int LSB = 2;

  // C0 control: a PART-SELECT fold, no call (golden+ours already agree).
  localparam bit [WIDTH-LSB-1:0] P_SEL   = START_ADDRESS[WIDTH-1:LSB];

  // C1: the Rggen shape — function RETURNS a part-select of a local.
  function automatic bit [WIDTH-LSB-1:0] f_partsel(bit [WIDTH-1:0] a, int n);
    bit [WIDTH-1:0] e;
    e = a + WIDTH'(n - 1);
    return e[WIDTH-1:LSB];
  endfunction
  localparam bit [WIDTH-LSB-1:0] C1_CALL = f_partsel(START_ADDRESS, BYTE_SIZE);

  // C2: same bit[] return type, but the function returns an ARITHMETIC value.
  function automatic bit [WIDTH-LSB-1:0] f_arith(int n);
    return (WIDTH-LSB)'(n + 16);
  endfunction
  localparam bit [WIDTH-LSB-1:0] C2_CALL = f_arith(BYTE_SIZE);

  // C3: same bit[] return type, function returns a plain LITERAL.
  function automatic bit [WIDTH-LSB-1:0] f_lit();
    return 20;
  endfunction
  localparam bit [WIDTH-LSB-1:0] C3_CALL = f_lit();

  // C4: INT-typed localparam fed by the part-select-returning function.
  function automatic int f_partsel_i(bit [WIDTH-1:0] a);
    bit [WIDTH-1:0] e;
    e = a;
    return e[WIDTH-1:LSB];
  endfunction
  localparam int C4_CALL = f_partsel_i(START_ADDRESS);

  // C5: bit[] localparam whose function assigns through a LOCAL then returns
  // the whole local (no select at all).
  function automatic bit [WIDTH-LSB-1:0] f_whole(int n);
    bit [WIDTH-LSB-1:0] e;
    e = (WIDTH-LSB)'(n + 16);
    return e;
  endfunction
  localparam bit [WIDTH-LSB-1:0] C5_CALL = f_whole(BYTE_SIZE);

  generate
    if (P_SEL == C1_CALL) begin : g_a
      assign o = 1'b1;
    end
    else if ((C2_CALL != 0) && (C3_CALL != 0) && (C4_CALL != 0) &&
             (C5_CALL != 0)) begin : g_a
      assign o = 1'b0;
    end
    else begin : g_a
      assign o = 1'bx;
    end
  endgenerate
endmodule
