// t2: bound KINDS -- literal, bare param, param+/-k, $clog2, nested paren,
// a multiplication, and a two-dimension packed default.
module dut #(
    parameter  int  W   = 8,
    parameter  type A0  = logic [7:0],
    parameter  type A1  = logic [W:0],
    parameter  type A2  = logic [W-1:0],
    parameter  type A3  = logic [W+1:2],
    parameter  type A4  = logic [$clog2(W)-1:0],
    parameter  type A5  = logic [(W*2)-1:0],
    parameter  type A6  = logic [W-1:0][3:0]
) (input A0 a0, input A1 a1, input A2 a2, input A3 a3,
   input A4 a4, input A5 a5, input A6 a6, output logic o);
  assign o = ^{a0,a1,a2,a3,a4,a5,a6};
endmodule
