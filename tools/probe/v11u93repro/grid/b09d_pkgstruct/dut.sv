package pk;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } pair_t;
endpackage
module sub ();
  module innermod (input pk::pair_t p, output logic [3:0] s);
    assign s = p.hi + p.lo;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
