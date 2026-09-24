// v11u93 v14 -- THE CONTROL: the same initial-in-generate in a MODULE home.
module sub ();
  wire [31:0] w_plain = 32'd11;
  generate
    if (1) begin : g
      wire [31:0] w_gen = 32'd12;
      initial begin
        $display("hi");
      end
    end
  endgenerate
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
