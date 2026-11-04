package p;
  logic [31:0] longer_name;
endpackage
module top (output logic [7:0] o, output logic [7:0] q);
  assign o = p::longer_name[7:0];
  assign q = p :: longer_name;
endmodule
