// § lvIdxPathIsRead154
interface tif; logic [3:0] adr; modport sub(input adr); endinterface
module mem(tif.sub sub, input logic [7:0] d, output logic [7:0] m [0:15]);
  always_comb begin m = '{default: 0}; m[sub.adr] = d; end
endmodule
module top(input logic [7:0] d, output logic [7:0] m [0:15]); tif b(); mem u(b, d, m); endmodule
