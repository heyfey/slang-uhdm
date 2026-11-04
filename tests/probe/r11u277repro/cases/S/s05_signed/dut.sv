// § strPortNetTsFromPortDecl277
module sub (o);
  output signed [15:0] o;
  wire (supply1, supply0) signed [15:0] o = -16'sd2;
endmodule
module dut (output logic signed [15:0] o);
  sub u_s (.o(o));
endmodule
