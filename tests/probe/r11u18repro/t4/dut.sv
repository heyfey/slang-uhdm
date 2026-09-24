// t4: INTERFACE and a NON-ANSI module header.
interface ifc #(parameter type IT = int, localparam type ILT = byte) ();
  IT a; ILT b;
endinterface
module nonansi (o);
  output logic o;
  parameter  type NPT = int;
  localparam type NLT = byte;
  NPT a; NLT b;
  assign o = (|{a}) ^ (|{b});
endmodule
module dut(output logic o);
  ifc i0 ();
  nonansi u0 (.o(o));
endmodule
