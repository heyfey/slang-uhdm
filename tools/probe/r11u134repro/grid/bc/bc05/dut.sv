// § pkgTdCloneBoundLoc134
module top(output logic [7:0] o);
   localparam int W = 8;
   typedef logic [W-1:0] t;
   t v = 8'h5C;
   assign o = v;
endmodule
