// r10earl109 arm g1 -- the CORPUS SHAPE reduced.
// usbdev_usbif.sv:20/54 :  localparam int PktW = $clog2(MaxPktSizeByte);
//                          input logic [PktW:0] in_size_i,
// The sibling bounds on the same listing (lines 50/53/55) are a literal and
// two `<param> - <lit>` expressions; both sides fold those at 64.
// MEASUREMENT ONLY.
module g1_child109 #(
  parameter int MaxPktSizeByte = 64,
  parameter int NEndpoints     = 12,
  parameter int NBufWidth      = 5,
  localparam int PktW          = $clog2(MaxPktSizeByte)   // int, value 6
) (
  input  logic                     clk_i,
  // THE HEAD SHAPE: a bare INT-typed parameter name as the LEFT bound
  input  logic [PktW:0]            in_size_i,
  // the SIBLINGS on the same listing, at 64 on both sides
  input  logic [NEndpoints-1:0]    in_stall_i,
  input  logic [NBufWidth - 1:0]   in_buf_i,
  output       [3:0]               in_endpoint_o,
  output logic                     set_sent_o
);
  assign in_endpoint_o = 4'd0;
  assign set_sent_o    = clk_i & in_size_i[0] & in_stall_i[0] & in_buf_i[0];
endmodule

module g1_home109;
  logic        clk;
  logic [6:0]  sz;
  logic [11:0] st;
  logic [4:0]  bf;
  logic [3:0]  ep;
  logic        ss;
  g1_child109 u_c (
    .clk_i(clk), .in_size_i(sz), .in_stall_i(st), .in_buf_i(bf),
    .in_endpoint_o(ep), .set_sent_o(ss)
  );
endmodule
