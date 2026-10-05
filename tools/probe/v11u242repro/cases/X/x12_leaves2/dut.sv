// § impCondFlipTakenLeaf242
// Taken leaves: parenthesized, unary minus, a system call, a sized literal, a concatenation, the condition true.
package fp;
  parameter int WM = 2;
  parameter int LB = 3;
  parameter int L1 = WM == 1 ? 1 : (LB);
  parameter int L2 = WM == 1 ? 1 : -LB;
  parameter int L4 = WM == 1 ? 1 : $clog2(LB);
  parameter int L5 = WM == 1 ? 1 : 4'd5;
  parameter logic [7:0] L6 = WM == 1 ? 8'd1 : {4'd2, 4'd3};
  parameter int L7 = WM != 1 ? LB : 1;
endpackage
module top import fp::*; #(parameter int P = 1) (input logic [15:0] a, output logic [L1-1:0] o1, output logic [L4:0] o4, output logic [L5-1:0] o5);
  assign o1 = a[L1-1:0];
  assign o4 = a[L4:0];
  assign o5 = a[0 +: L5];
  logic [L7-1:0] x;
  assign x = {L7{a[0]}};
endmodule
