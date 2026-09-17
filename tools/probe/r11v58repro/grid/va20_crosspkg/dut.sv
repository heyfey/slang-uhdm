// v11u58 va20 — THE FUNCTION LIVES IN ANOTHER PACKAGE (FuncStructVal's shape:
// the struct's package, the function's package and the reader are all
// different).  Does the stamp still reach `pk::C1`?
package pk;
  typedef struct packed {
    int unsigned A;   // 64
    int unsigned B;   // unsigned'(64)
    logic [7:0]  D;   // 32'(5)
  } u_t;
  localparam u_t C1 = '{ A: 64, B: unsigned'(64), D: 32'(5) };
  localparam u_t C2 = '{ A: 64, B: unsigned'(64), D: 32'(5) };  // never read
endpackage
package bld;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(pk::u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.B > 0);
    return r;
  endfunction
endpackage
module dut #(parameter bld::r_t R = bld::build(pk::C1)) (output logic [31:0] o);
  assign o = R.X;
endmodule
