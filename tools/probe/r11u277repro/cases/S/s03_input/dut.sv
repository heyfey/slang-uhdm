// § strPortNetTsFromPortDecl277
module sub (i, p);
  input [7:0] i;
  output [7:0] p;
  wire (strong1, weak0) [7:0] i = 8'd12;
  assign p = i;
endmodule
module dut (output logic [7:0] o);
  sub u_s (.i(8'd1), .p(o));
endmodule
