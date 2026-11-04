// § unitArrTd245
// a $unit fixed array typedef in two synthesizable modules (memory) with a range form
typedef logic [7:0] mem_t[0:3];
typedef logic [7:0] mem2_t[4];
module child(input logic clk, input logic [1:0] a, output logic [7:0] q);
  mem_t m;
  mem2_t n;
  always_ff @(posedge clk) q <= m[a] ^ n[a];
endmodule
module top(input logic clk, input logic [1:0] a, output logic [7:0] q);
  child u(.clk(clk), .a(a), .q(q));
endmodule
