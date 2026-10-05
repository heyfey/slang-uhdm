// § unitTdLawS245
// a $unit vector typedef on an interface port and a modport-qualified child port
typedef logic [3:0] nib_t;
interface ifc(input nib_t a);
  nib_t b;
  assign b = a;
  modport m(input b);
endinterface
module sub(ifc.m p, output nib_t o);
  assign o = p.b;
endmodule
module top(input logic [3:0] i, output logic [3:0] o);
  ifc u(.a(i));
  sub s(u, o);
endmodule
