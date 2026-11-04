// § implicitArgDimsInner155
interface ifc; function automatic logic f([2:0] x); return x[0]; endfunction endinterface
module top(output logic o); ifc u(); assign o = u.f(3); endmodule
