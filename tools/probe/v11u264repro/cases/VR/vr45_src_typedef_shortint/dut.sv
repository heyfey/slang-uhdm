// § refSignSrcSurelogSigned264v
module sub (output logic [31:0] o);
  typedef shortint st_t;
  localparam st_t A = 6;
  localparam int B = A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
