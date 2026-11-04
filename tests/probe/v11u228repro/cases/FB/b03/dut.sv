// § sizeBitNetIsVar228 — a package typedef of a bit packed array as an ANSI port, an interface bit port, and a var bit port
package p;
  typedef bit [4:0][1:0] bp_t;
endpackage
interface ifc (input bit [2:0][3:0] ip);
  wire [7:0] w = $size(ip);
endinterface
module dut (input p::bp_t pp, input var bit [6:0][1:0] pv, output logic [7:0] o1, o2, o3);
  ifc i (.ip('0));
  wire [7:0] w1 = $size(pp);
  wire [7:0] w2 = $size(pv);
  assign o1 = w1; assign o2 = w2; assign o3 = i.w;
endmodule
