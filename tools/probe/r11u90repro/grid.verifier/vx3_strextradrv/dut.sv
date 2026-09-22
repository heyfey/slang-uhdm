// v11u90 vx3 -- the dropped net is also DRIVEN by a separate continuous
// assign: does our cont_assign keep an Lhs pointing at a net nobody lists?
module sub (input logic [31:0] i, output logic [31:0] o);
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  assign w_str = i;
  assign o = w_str;
endmodule
module dut (input logic [31:0] i, output logic [31:0] o);
  sub u_s (.i(i), .o(o));
endmodule
