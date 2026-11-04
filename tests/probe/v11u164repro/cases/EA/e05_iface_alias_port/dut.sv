// § enumAliasClone161 — an interface alias of an interface enum read through a port
interface itf;
  typedef enum logic [1:0] {I0, I1, I2} e_t;
  typedef e_t f_t;
  f_t st;
endinterface
module top(output logic [1:0] o);
  itf i();
  assign i.st = i.I2;
  assign o = i.st;
endmodule
