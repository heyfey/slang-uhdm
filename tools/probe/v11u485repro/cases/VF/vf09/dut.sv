// § ovDefparamWinsValue485
interface ifc #(parameter A = 4); logic [A-1:0] a; endinterface
module top; ifc #(.A(5)) u(); defparam u.A = 6; endmodule
