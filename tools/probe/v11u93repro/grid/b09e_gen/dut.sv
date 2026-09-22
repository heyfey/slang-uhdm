module sub ();
  module innermod #(parameter int N = 2) (input logic [N-1:0] a, output logic [N-1:0] y);
    for (genvar i = 0; i < N; i++) begin : gl
      assign y[i] = ~a[i];
    end
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
