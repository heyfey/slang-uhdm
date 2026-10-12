// § varDeclInitMovesSharedTsEnd297
typedef struct packed { logic [1:0] a; logic b; } t_t;
interface ifc;
  var t_t x = 3'b011;
  modport m(input x);
endinterface
module c_m(ifc.m p, output logic [2:0] o);
  assign o = p.x;
endmodule
module dut(output logic [2:0] o);
  ifc i();
  c_m u(.p(i), .o(o));
endmodule
