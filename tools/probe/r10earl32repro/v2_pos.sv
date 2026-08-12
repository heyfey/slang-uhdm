// r10earl32 VERIFIER arm v2 — CALL ORIGINS AND ARGUMENT POSITIONS a1_kind SKIPS.
//
// The shipped gate is "the DIRECT vpiParent is uhdmfunc_call or uhdmtask_call".
// a1_kind measured package fn / module fn / task / nested / body / def-only /
// import 2x2 / sys-func / operation args.  It did NOT measure:
//
//   w1  a NAMED (connect-by-name) argument            mf(.v(m32w::P))
//   w2  a DEFAULTED formal skipped at the call site   md(m32w::P)      (2nd defaulted)
//   w3  a call in an INITIAL block (procedural, non-always)
//   w4  a call inside an ALWAYS_FF (clocked process)
//   w5  a call in a FOR-loop body and its BOUND
//   w6  a call in a CASE selector expression
//   w7  a call inside an IMMEDIATE ASSERT
//   w8  a NON-STATIC CLASS METHOD call on an object   obj.cm(m32w::P)
//   w9  a class CONSTRUCTOR argument                  new(m32w::P)
//   w10 a call argument to a call whose formal is `ref`/`const ref`
//   w11 a call inside a FUNCTION's DEFAULT ARGUMENT VALUE
//   w12 a call argument that is a pkg param of ANOTHER package read from inside
//       a CLASS METHOD in a module (ownPkgClassMethod47 does not apply)
package m32w;
  localparam logic [11:0] P = 12'h380;
  localparam int          I = 9;
endpackage

package m32w2;
  import m32w::*;
  localparam logic [11:0] Q = 12'h222;
endpackage

module m32wa (input logic clk, input logic [1:0] s_i,
              output logic [31:0] o1, o2, o3, o4, o5, o6, o7, o10, o11);
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction
  function automatic logic [31:0] md(logic [11:0] v, int k = 3); return {v, 20'h0} + k; endfunction
  function automatic logic [31:0] mr(const ref logic [11:0] v); return {v, 20'h0}; endfunction
  function automatic logic [31:0] mdef(logic [31:0] v = mf(m32w::P)); return v; endfunction

  assign o1 = mf(.v(m32w::P));                          // w1  NAMED argument
  assign o2 = md(m32w::P);                              // w2  defaulted 2nd formal

  always_comb begin : b3
    o3 = 32'h0;
  end
  initial begin : b3i
    o4 = mf(m32w::P);                                   // w3  INITIAL block
  end
  always_ff @(posedge clk) begin : b4
    o5 <= mf(m32w::P);                                  // w4  ALWAYS_FF
  end
  always_comb begin : b5
    o6 = 32'h0;
    for (int i = 0; i < m32w::I; i++)                   // w5b loop BOUND (no call)
      o6 = o6 + mf(m32w::P);                            // w5  in a FOR body
  end
  always_comb begin : b6
    case (mf(m32w::P))                                  // w6  CASE selector
      32'h380_00000: o7 = 32'd1;
      default:       o7 = 32'd0;
    endcase
  end
  always_comb begin : b7
    assert (mf(m32w::P) != 32'h0);                      // w7  immediate ASSERT
  end
  logic [11:0] rv;
  always_comb begin : b10
    rv  = 12'h380;
    o10 = mr(rv);                                       // w10 ref formal (control)
  end
  assign o11 = mdef();                                  // w11 default-arg call
endmodule

// w8/w9/w12 — class origins
class m32wc;
  logic [31:0] v;
  function new(logic [11:0] p = 12'h0); v = {p, 20'h0}; endfunction
  function automatic logic [31:0] cm(logic [11:0] p); return {p, 20'h0}; endfunction
  function automatic logic [31:0] cx();
    return cm(m32w::P);                                 // w12 other-pkg param in a class method
  endfunction
endclass

module m32wb (output logic [31:0] o8, o9, o12);
  m32wc h;
  initial begin
    h   = new(m32w::P);                                 // w9  constructor arg
    o8  = h.cm(m32w::P);                                // w8  method_func_call arg
    o12 = h.cx();
  end
endmodule

module m32wtop;
  logic clk; logic [1:0] s;
  logic [31:0] a1,a2,a3,a4,a5,a6,a7,a10,a11,b8,b9,b12;
  m32wa ua (.clk(clk), .s_i(s), .o1(a1), .o2(a2), .o3(a3), .o4(a4), .o5(a5),
            .o6(a6), .o7(a7), .o10(a10), .o11(a11));
  m32wb ub (.o8(b8), .o9(b9), .o12(b12));
endmodule
