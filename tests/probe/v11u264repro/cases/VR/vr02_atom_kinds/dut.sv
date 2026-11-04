// § refSignSrcSurelogSigned264v
module sub (output logic [63:0] o);
  localparam shortint SA = 7;
  localparam longint LA = 9;
  localparam byte BA = 3;
  localparam int I1 = SA;
  localparam int I2 = LA;
  localparam int I3 = BA;
  localparam shortint S2 = I1;
  localparam longint L2 = I2;
  localparam byte B2 = I3;
  localparam int unsigned U1 = I1;
  assign o = I1 + I2 + I3 + S2 + L2 + B2 + U1;
endmodule
module top(output logic [63:0] o);
  sub u(.o(o));
endmodule
