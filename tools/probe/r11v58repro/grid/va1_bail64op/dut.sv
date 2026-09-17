// v11u58 va1 — IS THE BAIL THE WIDTH, OR invalidValue?  CompileHelper.cpp:5423
// `if (invalidValue) return result;` fires AFTER adjustOpSize stamped that
// operand, exactly like the width bail at :5433.  r11u58's xd1 put a CAST
// OPERATION at a 128-bit member, so the two exits are confounded there.  Here
// the cast operation sits at a 64-BIT member: no width bail is possible.
// PATCH's law predicts A=32, Q=64, B=32, D=8 (all stamped).
// invalidValue-bail would predict A=32, Q=64, then B=64 and D=32 UNSTAMPED.
package pk;
  typedef struct packed {
    int unsigned A;   // 64                    -> 32 ?
    logic [63:0] Q;   // 64'({32'b0,32'b0})    -> 64 (cast operation)
    int unsigned B;   // unsigned'(64)         -> 32 ?
    logic [7:0]  D;   // 32'(5)                -> 8  ?
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.B > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ A: 64, Q: 64'({32'b0, 32'b0}), B: unsigned'(64),
                           D: 32'(5) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
