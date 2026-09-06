// r10v104 w2 -- INTERFACE-PORT and CROSS-INSTANCE select reads.  MEASUREMENT ONLY.
interface ifw2 ();
  localparam logic [3:0]  XP4  = {4{1'b1}};   // p1/p2: read only through the port
  localparam logic [31:0] XP32 = {32{1'b1}};
  logic dummy; assign dummy = 1'b0;
endinterface

interface ifw2c ();
  localparam logic [3:0] XC = {4{1'b1}};      // p3: read by a select INSIDE the interface (control)
  logic [XC[0]:0] wc; assign wc = '0;
endinterface

// p1 -- the user reads the interface parameter with a SELECT in a cont-assign
module usr_p1 (ifw2 i, output logic o);
  assign o = i.XP4[0] ^ i.XP32[0];
endmodule

// p2 -- the user reads it with a SELECT in a NET RANGE
module usr_p2 (ifw2 i, output logic o);
  logic [i.XP4[0]:0] w2; assign w2 = '0;
  assign o = w2[0];
endmodule

module w2_ifport104 (input logic ext, output logic o);
  ifw2  u_if  ();
  ifw2c u_ifc ();
  usr_p1 u_p1 (.i(u_if), .o());
  usr_p2 u_p2 (.i(u_if), .o());
  assign o = ext;
endmodule
