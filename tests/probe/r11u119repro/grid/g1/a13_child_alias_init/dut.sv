package pkg;
  typedef logic [7:0] u8_t;
endpackage
module child(output logic [7:0] o);
  pkg::u8_t a = 8'h3;
  assign o = a;
endmodule
module top(output logic [7:0] o);
  child u(.o(o));
endmodule
