// LAW A control (pass-102 law): the file-scope namesake is INSTANTIATED by dut, declared after dut
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  sub u_s ();
  innermod u_f (.a(x), .b(y));
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b); assign b = a; endmodule
