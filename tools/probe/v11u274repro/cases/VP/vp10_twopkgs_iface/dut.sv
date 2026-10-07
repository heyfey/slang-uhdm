// § pkgNetTsDimEnd274
package pa;
  wire [7:0] a [0:1];
endpackage
package pb;
  wire [1:0][7:0] b;
endpackage
interface ifc; import pa::*; import pb::*; logic [7:0] s; assign s = a[0] ^ b[1]; endinterface
module dut(output logic [7:0] o); ifc u(); assign o = u.s; endmodule
