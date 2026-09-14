// t1: MODULE, every type-parameter DECLARATION FORM in one module.
// ANSI parameter-port-list: written `parameter type` and written `localparam type`;
// module BODY: written `parameter type` and written `localparam type`.
module dut #(
    parameter  type PT1 = int,
    localparam type LT1 = int,
    parameter  int  PV1 = 1,
    localparam int  LV1 = 2
) (
    input  logic i,
    output logic o
);
  parameter  type PT2 = byte;
  localparam type LT2 = byte;
  parameter  int  PV2 = 3;
  localparam int  LV2 = 4;
  PT1 a; LT1 b; PT2 c; LT2 d;
  assign o = i ^ (|{a,b,c,d}) ^ PV1[0] ^ LV1[0] ^ PV2[0] ^ LV2[0];
endmodule
