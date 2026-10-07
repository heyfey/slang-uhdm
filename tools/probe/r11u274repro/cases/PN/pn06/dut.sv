// § pkgNetTsDimEnd274
package pc;
  wire [7:0] a_two [2][3];
  wire signed [3:0] a_sg [4];
  wire [0:0][7:0] a_one;
endpackage
interface ifc; import pc::*; logic x; endinterface
module dut (output logic [31:0] o);
  ifc i0();
  assign o = 0;
endmodule
