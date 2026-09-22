// v11u88 v11b -- a MODULE whose ONLY cont_assign is the declined one.
module sub (output logic [31:0] y);
  assign (pull0, pull1) #1 y = 32'd8;
endmodule

module dut (output logic [31:0] o);
  logic [31:0] sy;
  sub u_s (.y(sy));
  assign o = sy;
endmodule
