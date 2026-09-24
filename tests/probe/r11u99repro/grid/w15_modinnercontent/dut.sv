// nested module with a net, a param and a cont_assign -- is its def view filled?
module sub ();
  module innermod ();
    parameter int P = 7;
    wire [31:0] r;
    assign r = 32'd2;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
