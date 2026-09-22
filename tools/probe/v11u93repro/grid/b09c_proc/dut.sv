module sub ();
  module innermod (input logic clk, input logic [7:0] d, output logic [7:0] q2);
    localparam int L = 3;
    function automatic logic [7:0] inc(input logic [7:0] v); return v + L; endfunction
    logic [7:0] c;
    always_comb c = inc(d);
    always_ff @(posedge clk) q2 <= c;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
