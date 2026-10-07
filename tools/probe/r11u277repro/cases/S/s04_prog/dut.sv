// § strPortNetTsFromPortDecl277
program pr (o);
  output [3:0] o;
  wire (strong1, weak0) [3:0] o = 4'd3;
endprogram
module dut (output logic [3:0] o);
  pr u_p (.o(o));
endmodule
