// r11v50 BREAK grid b4 — WIDTHS, SIGNEDNESS and non-int VALUE KINDS at the
// substituted-leaf site, all on the one initializer shape the law moves
// (a multiply, which `paramIntEnc` never marked).
package w54;
  typedef enum logic [7:0] { EA = 8, EB = 12 } e_t;
  parameter int unsigned A = 16;
  parameter int unsigned B = 3;

  parameter int unsigned  W_INTU = A * B;          // f01 int unsigned, 32
  parameter int           W_INTS = A * B;          // f02 int (signed), 32
  parameter integer       W_INTG = A * B;          // f03 integer, 32
  parameter longint       W_LONG = A * B;          // f04 longint, 64
  parameter longint unsigned W_LONU = A * B;       // f05 longint unsigned, 64
  parameter shortint      W_SHRT = A * B;          // f06 shortint, 16
  parameter byte          W_BYTE = A * B;          // f07 byte, 8
  parameter bit [63:0]    W_BIT64 = A * B;         // f08 bit [63:0]
  parameter logic [15:0]  W_L16  = A * B;          // f09 logic [15:0]
  parameter logic signed [15:0] W_SL16 = A * B;    // f10 logic signed [15:0]
  parameter int unsigned  W_ENUM = A * B / 4;      // f11 a divide-under-multiply
  parameter int unsigned  W_LIT  = 48;             // f12 control: a plain literal
endpackage

module m54 import w54::*; (input logic clk);
  logic [W_INTU -1:0] c01;
  logic [W_INTS -1:0] c02;
  logic [W_INTG -1:0] c03;
  logic [W_LONG -1:0] c04;
  logic [W_LONU -1:0] c05;
  logic [W_SHRT -1:0] c06;
  logic [W_BYTE -1:0] c07;
  logic [W_BIT64-1:0] c08;
  logic [W_L16  -1:0] c09;
  logic [W_SL16 -1:0] c10;
  logic [W_ENUM -1:0] c11;
  logic [W_LIT  -1:0] c12;
endmodule

module tb54;
  logic clk;
  m54 u (.clk(clk));
endmodule
