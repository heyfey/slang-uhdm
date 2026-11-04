// v11u90 vx16 -- the dropped name is used as a child instance's PORT
// CONNECTION in the same body (the classic implicit-net context).
module leaf (input logic [31:0] i, output logic [31:0] o);
  assign o = i;
endmodule
module sub (output logic [31:0] o);
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  leaf u_l (.i(w_str), .o(o));
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
