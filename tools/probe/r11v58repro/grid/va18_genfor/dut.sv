// v11u58 va18 — THE READ INSIDE A LIVE `generate for` BODY.  The liveness
// filter must keep this one armed (a GenerateBlockArray entry).
package pk;
  typedef struct packed {
    int unsigned A;   // 64
    int unsigned B;   // unsigned'(64)
    logic [7:0]  D;   // 32'(5)
  } u_t;
  function automatic int unsigned wid(u_t c);
    return c.A[7:0];
  endfunction
  localparam u_t F1 = '{ A: 64, B: unsigned'(64), D: 32'(5) };  // read in the loop
  localparam u_t F2 = '{ A: 64, B: unsigned'(64), D: 32'(5) };  // never read
endpackage
module dut (output logic [31:0] o);
  logic [31:0] w [0:1];
  for (genvar i = 0; i < 2; i++) begin : g
    localparam int unsigned L = pk::wid(pk::F1) + i;
    assign w[i] = L;
  end
  assign o = w[0] + w[1];
endmodule
