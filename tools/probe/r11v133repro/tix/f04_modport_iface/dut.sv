// § hpTrailSelIdxNamesByPath133
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
    logic [1:0] k;
  } w_t;
endpackage
interface ifc;
  p::e_t s;
  logic [1:0] i;
  modport mp(input s, input i);
endinterface
module sub(ifc.mp b, output logic o);
  assign o = b.s.sat[b.i];
endmodule
module dut(input p::e_t s, input logic [1:0] i, output logic o);
  ifc u();
  assign u.s = s;
  assign u.i = i;
  sub x(.b(u), .o(o));
endmodule
