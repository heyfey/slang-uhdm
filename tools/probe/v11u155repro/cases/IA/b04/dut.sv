// § implicitArgDimsInner155
module top #(parameter int W = 4) (); function automatic logic f([W-1:0] x); return x[0]; endfunction endmodule
