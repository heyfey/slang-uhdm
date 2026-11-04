// § elabNetTdCloneNoAlias134
module sub(output logic [3:0] o);
   typedef logic [3:0] t4;
   wire t4 w = 4'd3;
   assign o = w;
endmodule
module top(output logic [3:0] o);
   sub u(.o(o));
endmodule
