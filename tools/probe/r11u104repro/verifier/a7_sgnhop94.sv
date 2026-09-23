// v11u94 attack arm a7 -- signed-BIN name hops, 1-bit signed literals, X-free wide readers, type-param nets
package a7p;
  localparam logic signed [7:0] SA = 8'sb10101010;
  localparam logic [7:0] SB = SA;
  localparam logic signed [7:0] SC = SA;
  localparam SD = SA;
  localparam logic [7:0] S1 = 1'sb1;
  localparam logic [7:0] S0 = 1'sb0;
  localparam logic signed [3:0] SW = 8'sb10101010;
  localparam logic [15:0] SX = 8'sB1000_0001;
  localparam bit signed [63:0] S64 = 64'sb1000000000000000000000000000000000000000000000000000000000000001;
  localparam logic [7:0] UB = 8'b1000_0001;
endpackage
module a7tp #(parameter type T = logic [3:0]) (output logic [15:0] q);
  wire T tSA = a7p::SA;
  wire T tUB = a7p::UB;
  assign q = tSA ^ tUB;
endmodule
module a7_sgnhop94 (output logic [15:0] o);
  wire [3:0] hSB4 = a7p::SB;
  wire [3:0] hSC4 = a7p::SC;
  wire [3:0] hSD4 = a7p::SD;
  wire [15:0] hSB16 = a7p::SB;
  wire [3:0] hS14 = a7p::S1;
  wire [3:0] hS04 = a7p::S0;
  wire [15:0] hS116 = a7p::S1;
  wire [1:0] hSW2 = a7p::SW;
  wire [7:0] hSW8 = a7p::SW;
  wire [3:0] hSX4 = a7p::SX;
  wire [31:0] hSX32 = a7p::SX;
  wire [7:0] hS648 = a7p::S64;
  wire [127:0] hS64w = a7p::S64;
  wire [3:0] hUB4 = a7p::UB;
  wire [15:0] q1, q2;
  a7tp u1 (.q(q1));
  a7tp #(.T(logic [5:0])) u2 (.q(q2));
  assign o = q1 ^ q2 ^ hSB4 ^ hSC4 ^ hSD4 ^ hSB16 ^ hS14 ^ hS04 ^ hS116 ^ hSW2 ^ hSW8 ^ hSX4 ^ hSX32 ^ hS648 ^ hS64w[15:0] ^ hUB4;
endmodule
