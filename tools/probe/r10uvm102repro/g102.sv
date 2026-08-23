package p102;
  parameter PB  = 'b101;
  parameter PH  = 'h1a;
  parameter PO  = 'o17;
  parameter PD  = 'd13;
  parameter PSB = 3'b101;
  parameter PSH = 8'h1a;
  parameter PSO = 6'o17;
  parameter PSD = 5'd13;
  parameter PU  = 13;
  parameter PZ  = '0;

  localparam LPB = 'b101;
  parameter int TPB = 'b101;
  parameter logic [7:0] RPB = 'b101;

  class C102 #(parameter CB = 'b101,
               parameter int CTB = 'b101,
               parameter [7:0] CRB = 'b101);
  endclass
endpackage

package q102;
  import p102::*;
endpackage

module child102 #(
  parameter HB = 'b101,
  parameter int HTB = 'b101,
  parameter [7:0] HRB = 'b101
) ();
  parameter MB  = 'b101;
  parameter MH  = 'h1a;
  parameter MO  = 'o17;
  parameter MD  = 'd13;
  parameter MSB = 3'b101;
  parameter MSH = 8'h1a;
  parameter MSO = 6'o17;
  parameter MSD = 5'd13;
  parameter MU  = 13;
  parameter MZ  = '0;
  localparam MLB = 'b101;
  parameter int MTB = 'b101;
  parameter logic [7:0] MRB = 'b101;
endmodule

module top102;
  import p102::*;
  import q102::*;
  child102 u();
endmodule
