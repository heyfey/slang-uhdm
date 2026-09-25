// § implicitArgDimsInner155
module top(output logic o); function automatic logic f([2:0] x = 3); return x[0]; endfunction assign o = f(); endmodule
