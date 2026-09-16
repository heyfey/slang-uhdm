// xb5 - imported materialized copies, class body, real/string/time neighbours
package pk;
  parameter logic [1:0] C0 = 2'b01;
  parameter logic [3:0] IC = {C0, 2'b11};
  parameter logic [3:0] IR = {2{C0}};
  parameter logic [3:0] IB = {C0, 2'b11} | 4'b0001;
  parameter real        RP = 1.5;
  parameter string      SP = "ab";
  parameter time        TP = 10ns;
  class cbody;
    localparam logic [3:0] KC = {C0, 2'b11};
    localparam logic [3:0] KR = {2{C0}};
  endclass
endpackage

module top;
  import pk::*;
  localparam logic [3:0] LC = IC;
  localparam logic [3:0] LR = IR;
  localparam logic [3:0] LB = IB;
  logic [3:0] a = LC ^ LR ^ LB;
  real        r = pk::RP;
  string      s = pk::SP;
  time        t = pk::TP;
endmodule
