package pkg;
  typedef logic [7:0] u8_t;
endpackage
interface bus;
  pkg::u8_t a = 8'h3;
endinterface
module top(output logic [7:0] o);
  bus b();
  assign o = b.a;
endmodule
