// v11u90 vy18 -- the delay name resolves to an ENUM VALUE, not a parameter:
// the law's member walk must decline it and leave the base's constant.
module sub (output logic [31:0] o);
  typedef enum int { D = 4, E = 5 } e_t;
  logic [31:0] c;
  assign #D c = 32'd10;
  assign o = c;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
