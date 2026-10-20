// § ansiNoDirNetPortUntyped420
interface ifc(wire [3:0] b);
endinterface
module top;
  wire [3:0] w;
  ifc u(w);
endmodule
