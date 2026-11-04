// § ifCaConstDelayPerCell301
module sub (output logic [31:0] p, q);
  assign #4 p = 32'd1, q = 32'd2;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] p, q;
  sub u (.p(p), .q(q));
  assign o = p ^ q;
endmodule
