// § structMemberDefaultParamRef430
interface ifc #(parameter c = 4'h5) ();
struct { bit [3:0] lo = c; } p1;
endinterface
module top (); ifc u(); endmodule
