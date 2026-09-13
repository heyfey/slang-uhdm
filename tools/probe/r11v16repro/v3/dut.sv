// v3 — THE FENCE HOLE candidate: struct members that are a packed ARRAY OF
// PACKED STRUCT and a packed UNION.  `ok16` only rejects a DIRECT
// PackedStructType member.
package p;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } inner_t;
  typedef union packed { logic [15:0] w; inner_t s; } u_t;
  typedef struct packed { int unsigned n; inner_t [1:0] arr; } arrstruct_t;
  typedef struct packed { int unsigned m; u_t u; } withunion_t;
  function automatic arrstruct_t buildA();
    arrstruct_t c;
    c.n   = 5;
    c.arr = '{'{a:8'hAA, b:8'hBB}, '{a:8'hCC, b:8'hDD}};
    return c;
  endfunction
  function automatic withunion_t buildU();
    withunion_t c;
    c.m = 7;
    c.u = 16'h1234;
    return c;
  endfunction
endpackage

module dut #(
    parameter p::arrstruct_t CA = p::buildA(),
    parameter p::withunion_t CU = p::buildU()
) (
    output wire [31:0] o_an,
    output wire [31:0] o_um
);
  assign o_an = CA.n;
  assign o_um = CU.m;
endmodule
