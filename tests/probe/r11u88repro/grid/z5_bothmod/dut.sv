// r11u88 z5 -- LAW B x the MODULE home: the decline is
// `compileContinuousAssignment`'s, which every home shares.  Does the module
// listing decline too, and do WE mint the cell there?
module sub (output logic [31:0] o);
  logic [31:0] c_both;
  logic [31:0] c_str;
  logic [31:0] c_del;
  assign (pull1, supply0) #3 c_both = 32'd10;
  assign (strong1, weak0) c_str = 32'd9;
  assign #5 c_del = 32'd8;
  assign o = c_both ^ c_str ^ c_del;
endmodule

module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
