// LAW A control: the file-scope namesake is a TOP declared BEFORE dut (it takes the bare key first)
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
