// § unitTdLawS245
// a synthesizable module with $unit vector and int typedef variables and a function
typedef logic [7:0] byte_t;
typedef int unsigned cnt_t;
module top(input logic clk, input logic [7:0] d, output logic [7:0] q);
  byte_t r;
  cnt_t n;
  function automatic byte_t inc(byte_t v); return v + 8'd1; endfunction
  always_ff @(posedge clk) begin
    r <= inc(d);
    n <= n + 1;
  end
  assign q = r;
endmodule
