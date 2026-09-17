// v11u58 va2 — THE SYSTEM-CALL ARGUMENT.  `pkgPatCallArgParam58` keys on
// slang's InvocationExpression inside a parameter context.  `$bits(pk::S1)`
// and `$clog2(pk::S3)` are calls in a parameter context too.  Does the GATE
// fire, and does GOLDEN stamp?  S2 is the control: never read at all.
package pk;
  typedef struct packed {
    int unsigned A;   // 64
    int unsigned B;   // unsigned'(64)
    logic [7:0]  D;   // 32'(5)
  } u_t;
  localparam u_t S1 = '{ A: 64, B: unsigned'(64), D: 32'(5) };  // $bits arg
  localparam u_t S2 = '{ A: 64, B: unsigned'(64), D: 32'(5) };  // NEVER read
  localparam u_t S3 = '{ A: 64, B: unsigned'(64), D: 32'(5) };  // $clog2 arg
endpackage
module dut (output logic [31:0] o);
  localparam int L1 = $bits(pk::S1);
  localparam int L3 = $clog2(pk::S3);
  assign o = L1 + L3;
endmodule
