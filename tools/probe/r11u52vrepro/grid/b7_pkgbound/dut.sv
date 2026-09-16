// b7 — the element typedef used ACROSS scopes: a body typedef whose element
// bound names a parameter, referenced from a NET, a VARIABLE, a PORT-connected
// instance and a FUNCTION argument.  Each reference mints its own per-reference
// COPY through copyArrayTypedefTs — the path the law rewrote to clone and
// re-scope.  More reference kinds than the implementer's x2 arm.
module leaf #(parameter int N = 4, parameter int DEPTH = 8) (
  input logic clk,
  output logic [N-1:0] o
);
  typedef logic [N-1:0] mem_t [DEPTH];
  mem_t mem;              // net/variable reference copy
  mem_t mem2;             // a SECOND reference to the same typedef
  function automatic logic [N-1:0] rd(input int i);
    mem_t loc;            // a FUNCTION-LOCAL variable of the body typedef
    loc = mem;
    return loc[i];
  endfunction
  assign o = rd(0);
endmodule

module dut #(parameter int N = 4, parameter int DEPTH = 8) (
  input logic clk,
  output logic [N-1:0] o1,
  output logic [5:0] o2
);
  leaf #(.N(N),   .DEPTH(DEPTH)) i1 (.clk(clk), .o(o1));
  leaf #(.N(6),   .DEPTH(3))     i2 (.clk(clk), .o(o2));
endmodule
