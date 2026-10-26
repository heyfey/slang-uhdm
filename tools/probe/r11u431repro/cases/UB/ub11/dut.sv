// § unitParamNameBindsDesign431
localparam CF = 2;
interface ifc;
localparam CF = 1;
logic [3:0] c;
logic y;
always_comb y = c[CF];
endinterface
module top;
ifc u();
endmodule
