// v11u58 va12 — A NESTED STRUCT MEMBER.  The inner member is itself a packed
// struct (48 bits) whose element is a nested pattern operation.  Does golden
// stamp the nested operation to 48, and do we?
package pk;
  typedef struct packed { int unsigned P; logic [15:0] Q; } in_t;  // 48
  typedef struct packed {
    int unsigned A;   // 64  -> 32
    in_t         N;   // nested '{...} -> 48 ?
    logic [7:0]  D;   // 32'(5) -> 8
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.D > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ A: 64, N: '{ P: 7, Q: 16'd3 }, D: 32'(5) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
