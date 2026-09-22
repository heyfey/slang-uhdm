// v11u90 vx21 -- supply0/supply1 used as a DRIVE STRENGTH inside the parens
// (not as a net type), beside the net-type controls.
module sub (output logic [31:0] o);
  wire (supply1, supply0) [31:0] w_sup = 32'd12;
  supply0 s0;
  supply1 s1;
  wire [31:0] w_plain = 32'd11;
  assign o = w_plain;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
