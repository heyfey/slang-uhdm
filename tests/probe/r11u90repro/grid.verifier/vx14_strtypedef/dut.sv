// v11u90 vx14 -- the strength declaration uses a TYPEDEF'd data type.
package pk;
  typedef logic [31:0] w32_t;
endpackage
module sub (output logic [31:0] o);
  pk::w32_t w_plain = 32'd11;
  wire (strong1, weak0) pk::w32_t w_str = 32'd12;
  assign o = w_plain;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
