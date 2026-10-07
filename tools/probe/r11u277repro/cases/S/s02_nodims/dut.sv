// § strPortNetTsFromPortDecl277
module sub (o, p);
  output o;
  output p;
  wire (pull1, pull0) o = 1'b1;
  wire p = 1'b0;
endmodule
module dut (output logic o, output logic q);
  sub u_s (.o(o), .p(q));
endmodule
