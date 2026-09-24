// § elabCloneFullNameUnstored137
interface bus(input logic clk);
  logic d, q;
  function automatic logic inv(input logic v);
    logic t;
    t = ~v;
    return t;
  endfunction
  always_ff @(posedge clk) q <= inv(d);
endinterface
module top(input logic clk, output logic o);
  bus b(.clk(clk));
  assign o = b.q;
endmodule
