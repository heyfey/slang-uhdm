package pk;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pair_t;
endpackage
module innermod (input pk::pair_t p, output logic [3:0] s);
  assign s = p.hi + p.lo;
endmodule
module dut (output logic [31:0] o);
  wire [3:0] s1;
  innermod u_i (.p('0), .s(s1));
  assign o = 32'd0;
endmodule
