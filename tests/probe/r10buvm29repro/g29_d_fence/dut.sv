// r10buvm29 arm D — THE FENCE (NEGATIVE arm).  Every BARE streaming
// concatenation the corpus actually contains: slang wraps each of these in a
// compiler-inserted ConversionExpression (ConversionKind::StreamingConcat /
// BitstreamCast) with NO cast syntax, and golden emits NO cast operation.
// A patch that keys on the slang CONVERSION instead of the WRITTEN `'` lights
// this whole arm up.  Shapes copied from the six uhdm2rtlil stream rows
// (StreamOp, StreamOpImplicitSliceSize, StreamOperatorBitReverseFunction,
// jeras_reverse, rp32/r5p_alu) and the Verilator/Google stream tests.
module d29 (input logic [7:0] i, output logic [15:0] o1, output logic [15:0] o2);
  logic [7:0] x, y;
  logic [7:0] t0;
  bit __a[];
  int q;
  function automatic logic [7:0] bitrev (input logic [7:0] val);
    bitrev = {<<{val}};                    // bare, function-return target
  endfunction
  assign o1 = {<< 8 {x, y}};               // bare, continuous assign
  assign o2 = {>> 8 {x, y}};
  always_comb begin
    t0 = {<< 2 {i[3:0], 4'h1}};            // bare, procedural
    x  = {<<{i}};                          // bare, no slice size
    y  = bitrev(i);
    q  = {<< bit { __a }};                 // bare, dynamic array source
  end
  initial begin
    logic [7:0] z;
    z = {<< {i}};
  end
endmodule
