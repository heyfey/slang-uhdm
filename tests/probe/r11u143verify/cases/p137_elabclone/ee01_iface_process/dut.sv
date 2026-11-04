// § elabCloneFullNameUnstored137
// case ee01: an interface with its own always block and function, instantiated in top
interface bus_if(input logic clk);
  logic [3:0] d, q;
  function automatic logic [3:0] nx(input logic [3:0] v); return v + 1; endfunction
  always_ff @(posedge clk) q <= nx(d);
endinterface
module top(input logic clk, input logic [3:0] d, output logic [3:0] q);
  bus_if b(.clk(clk));
  assign b.d = d;
  assign q = b.q;
endmodule
