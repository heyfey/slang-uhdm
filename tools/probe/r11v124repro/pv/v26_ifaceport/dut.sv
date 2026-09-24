// § paramValueIsDefRhs124
interface bus #(parameter W=4); logic [W-1:0] d; modport mp(output d); endinterface
module drv(bus.mp b); assign b.d = '1; endmodule
module top(output logic [5:0] o); bus #(.W(6)) b(); drv u(.b(b)); assign o = b.d; endmodule
