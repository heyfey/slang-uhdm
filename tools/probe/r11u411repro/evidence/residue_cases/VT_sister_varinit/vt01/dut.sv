// residue, sister ground (ModuleEmit elaborated variable initializer): literal masked to the variable width
module top(output logic [7:0] o);
  logic a = 3;
  logic b = 2;
  logic [1:0] c = 7;
  bit d = 2;
  logic [3:0] f = 'hFF;
  logic [3:0] g = 8'hA5;
  logic [3:0] h = 17;
  int e = 5;
  logic signed [2:0] sg = 5;
  assign o = {a, b, c, d, f[0], g[0], h[0]};
endmodule
