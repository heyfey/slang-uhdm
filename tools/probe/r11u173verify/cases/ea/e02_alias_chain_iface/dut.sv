// § enumAliasClone161 — a three-level alias chain inside an interface
interface a_if;
  typedef enum logic [1:0] { I0, I1, I2 } s_e;
  typedef s_e s1_t;
  typedef s1_t s2_t;
  s2_t st;
endinterface
module top(output logic [1:0] o);
  a_if b();
  assign b.st = b.I2;
  assign o = b.st;
endmodule
