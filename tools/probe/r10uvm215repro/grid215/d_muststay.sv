// r10uvm215 GRID ARM D — THE MUST-STAY CONTROL.  Every modport shape this
// campaign already emits correctly, in one file: if the law fires anywhere
// here, it is too wide.  The `ref` member is § modportRefDirInout's own cell
// (direction 3 by Surelog's getVpiDirection default), the header-port members
// are § modportHdrPortNetKeyword's, and the expression ports are
// § modportExprPort's — all three are earlier landings whose cells must not
// move.
//
// d1 plain in/out/inout members
// d2 a `ref` member
// d3 interface HEADER-PORT members (input wire clk / input logic rst)
// d4 expression ports: .P(r[3:0]) and .Q(x) and .R(2)
// d5 a modport with ONE simple port and NOTHING else (the minimum survivor)

interface d1_if;
  logic a, b;
  wire c;
  modport mp (input a, output b, inout c);
endinterface

interface d2_if;
  logic data_sys;
  modport mp (ref data_sys);
endinterface

interface d3_if (input wire clk, input logic rst);
  logic d;
  modport mp (input clk, input rst, output d);
endinterface

interface d4_if;
  logic [3:0] r;
  logic x;
  modport mp (input .P(r[3:0]), input .Q(x), input .R(2));
endinterface

interface d5_if;
  logic only_one;
  modport mp (input only_one);
endinterface

module top;
  wire clk3;
  logic rst3;
  d1_if u1();
  d2_if u2();
  d3_if u3(clk3, rst3);
  d4_if u4();
  d5_if u5();
endmodule
