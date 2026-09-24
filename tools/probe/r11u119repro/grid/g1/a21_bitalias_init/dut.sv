package pkg;
  typedef bit [7:0] b8_t;
endpackage
module top(output logic [7:0] o);
  pkg::b8_t a = 8'h3;
  assign o = a;
endmodule
