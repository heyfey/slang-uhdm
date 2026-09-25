// § implicitArgDimsInner155
function automatic logic f([2:0] x); return x[0]; endfunction
module top(output logic o); assign o = f(3); endmodule
