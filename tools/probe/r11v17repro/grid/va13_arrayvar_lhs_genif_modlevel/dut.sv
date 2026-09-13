// LAW 1's negative twin: a module-level unpacked-array VARIABLE (driven by a
// process so Surelog makes it a VAR) must keep binding.
module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] arr[2];
  logic [31:0] b;
  always_comb b = a;
  if (1) begin : gb
    assign arr = '{b, b};
  end
  assign o = arr[0];
endmodule
