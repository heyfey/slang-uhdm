// § implicitArgDimsInner155
module top(output logic o); function automatic logic f([0:3] a); return a[0]; endfunction assign o = f(4'b1000); endmodule
