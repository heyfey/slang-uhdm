// § unitTdLawS245
// a $unit vector typedef on an interface variable read through a modport
typedef logic [3:0] nib_t;
interface ifc;
  nib_t d;
  modport m(input d);
endinterface
module sub(ifc.m p, output logic [3:0] o);
  assign o = p.d;
endmodule
module top(input logic [3:0] i, output logic [3:0] o);
  ifc u();
  assign u.d = i;
  sub s(.p(u), .o(o));
endmodule
