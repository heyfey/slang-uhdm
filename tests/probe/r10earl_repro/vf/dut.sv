// vf.sv — THE FOUR-MODULE EXPERIMENT (pass-11 ranked residue (1)).
// Which module DEF listings get a *raw import copy* of a wildcard-imported
// package parameter and which get an *elaborated/flattened* one?
// 2x2 over the two candidate distinguishers visible in the Earlgrey headers:
//   header import (module X import pkg::*;)  vs  BODY import
//   parameter port list #( ... )             vs  none
package vfp;
  parameter int BusWidth = 8;

  typedef struct packed {
    logic                req;
    logic                rd;
    logic [BusWidth-1:0] prog_data;
  } req_t;

  parameter req_t REQ_DEFAULT = '{
    req:       1'b0,
    rd:        1'b0,
    prog_data: '0
  };
endpackage

// A: HEADER import, NO parameter port list   (flash_ctrl / flash_phy shape)
module vfa import vfp::*; (
  input  logic clk_i,
  output req_t o
);
  assign o = REQ_DEFAULT;
endmodule

// B: HEADER import, WITH parameter port list (flash_phy_core shape)
module vfb import vfp::*; #(
  parameter int Aw = 10
) (
  input  logic clk_i,
  output req_t o
);
  logic [Aw-1:0] unused;
  assign o = REQ_DEFAULT;
endmodule

// C: BODY import, NO parameter port list
module vfc (
  input  logic clk_i,
  output vfp::req_t o
);
  import vfp::*;
  assign o = REQ_DEFAULT;
endmodule

// D: BODY import, WITH parameter port list   (flash_mp / flash_erase_ctrl shape)
module vfd #(
  parameter int Aw = 10
) (
  input  logic clk_i,
  output vfp::req_t o
);
  import vfp::*;
  logic [Aw-1:0] unused;
  assign o = REQ_DEFAULT;
endmodule

module vftop;
  logic clk;
  vfp::req_t a, b, c, d;
  vfa u_a (.clk_i(clk), .o(a));
  vfb u_b (.clk_i(clk), .o(b));
  vfc u_c (.clk_i(clk), .o(c));
  vfd u_d (.clk_i(clk), .o(d));
endmodule
