// § pkgNetTsDimEnd274
package pc;
  `define D [0:1]
  `define PD [1:0][3:0]
  wire [7:0] a_m `D;
  wire `PD a_pm;
  wire [7:0] a_n [0:1], a_o [0:3];
endpackage
module dut (output logic [31:0] o);
  assign o = 0;
endmodule
