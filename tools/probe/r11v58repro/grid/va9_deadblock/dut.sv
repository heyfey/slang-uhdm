// v11u58 va9 — THE SAME DEFECT CLASS ONE LEVEL DOWN: the gated read stands in
// a DEAD GENERATE BLOCK of a LIVE module.  H1's reader is inside `if (0)`,
// H2's inside `if (1)` (the live control), H3 is never read.
package pk;
  typedef struct packed {
    int unsigned A;   // 64
    int unsigned B;   // unsigned'(64)
    logic [7:0]  D;   // 32'(5)
  } u_t;
  function automatic int unsigned wid(u_t c);
    return c.A[7:0];
  endfunction
  localparam u_t H1 = '{ A: 64, B: unsigned'(64), D: 32'(5) };  // DEAD block
  localparam u_t H2 = '{ A: 64, B: unsigned'(64), D: 32'(5) };  // LIVE block
  localparam u_t H3 = '{ A: 64, B: unsigned'(64), D: 32'(5) };  // never read
endpackage
module dut (output logic [31:0] o);
  logic [31:0] w1, w2;
  if (0) begin : dead
    localparam int unsigned L1 = pk::wid(pk::H1);
    assign w1 = L1;
  end
  if (1) begin : live
    localparam int unsigned L2 = pk::wid(pk::H2);
    assign w2 = L2;
  end
  assign o = w2;
endmodule
