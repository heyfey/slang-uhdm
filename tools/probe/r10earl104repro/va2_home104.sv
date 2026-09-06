// r10v104 va2 -- CROSS-SCOPE readers and HOMES.  MEASUREMENT ONLY.
module subz104 #(parameter P = 0) (output logic z); assign z = |P; endmodule

interface if104 #(parameter int WI = 4) ();
  localparam logic [WI-1:0] XI = {WI{1'b1}};   // h6: interface, no reader
  logic [1:0] wi; assign wi = '0;
endinterface

interface if104r #(parameter int WI = 4) ();
  localparam logic [WI-1:0] XIR = {WI{1'b1}};  // h7: interface, cont-assign select reader
  logic wir; assign wir = XIR[0];
endinterface

package pk104;
  parameter logic [3:0] PXP = {4{1'b1}};       // h8: package parameter (fence: inPackage)
endpackage

// h1 -- read ONLY hierarchically from the PARENT
module m_h1_4 (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  assign o = 1'b0;
endmodule
module m_h1_32 (output logic o);
  localparam logic [32-1:0] X = {32{1'b1}};
  assign o = 1'b0;
endmodule

// h4 -- three instances of one span, no reader
module m_h4 #(parameter int W = 4) (output logic o);
  localparam logic [W-1:0] X = {W{1'b1}};
  assign o = 1'b0;
endmodule

// h5 -- three instances of one span, cont-assign select reader
module m_h5 #(parameter int W = 4) (output logic o);
  localparam logic [W-1:0] X = {W{1'b1}};
  assign o = X[0];
endmodule

// h9 -- an IMPORTED package parameter used by a select read in the module
module m_h9 (output logic o);
  import pk104::*;
  assign o = PXP[0];
endmodule

module va2_home104(input logic ext, output logic o);
  m_h1_4  u_h1_4  (.o());
  m_h1_32 u_h1_32 (.o());
  m_h4 #(.W(4))  u_h4a (.o());
  m_h4 #(.W(4))  u_h4b (.o());
  m_h4 #(.W(32)) u_h4c (.o());
  m_h5 #(.W(4))  u_h5a (.o());
  m_h5 #(.W(4))  u_h5b (.o());
  m_h5 #(.W(32)) u_h5c (.o());
  m_h9 u_h9 (.o());
  if104  #(.WI(4))  u_if4  ();
  if104r #(.WI(4))  u_ifr4 ();
  // the hierarchical read of h1's X
  logic hh4, hh32;
  assign hh4  = u_h1_4.X[0];
  assign hh32 = u_h1_32.X[0];
  assign o = hh4 ^ hh32;
endmodule
