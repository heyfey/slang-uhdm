// xb1 - concat/replication in EXOTIC positions, package scope (ELAB listing)
package pk;
  parameter logic [1:0] C0 = 2'b01;
  parameter logic [1:0] C3 = 2'b11;
  function automatic logic [1:0] f4(input logic [3:0] x);
    return x[1:0];
  endfunction
  // X1: concat in the CONDITION of a conditional
  parameter logic [1:0] X1 = ({C0, C3} == 4'b0111) ? C0 : C3;
  // X2: conditional WITH a concat branch, nested under a binary op
  parameter logic [1:0] X2 = (C0[0] ? {C0} : C3) + 2'b01;
  // X3: part-select of a concat
  parameter logic [1:0] X3 = {C0, C3}[3:2];
  // X4: concat inside a system function call
  parameter int X4 = $clog2({C0, C3});
  // X5: concat inside a USER function call
  parameter logic [1:0] X5 = f4({C0, C3});
  // X6: replication under a unary operator
  parameter logic [3:0] X6 = ~{2{C0}};
  // X7: concat under a comparison
  parameter logic X7 = ({C0, C3} != 4'b0000);
  // X8: bare replication (top level)
  parameter logic [3:0] X8 = {2{C0}};
  // X9: concat nested inside a conditional branch inside a concat
  parameter logic [3:0] X9 = {(C0[0] ? C0 : C3), C3};
endpackage

module top;
  // module-scope controls: the SAME shapes must stay folded
  localparam logic [1:0] M1 = ({pk::C0, pk::C3} == 4'b0111) ? pk::C0 : pk::C3;
  localparam logic [3:0] M2 = {2{pk::C0}};
  localparam logic [3:0] M3 = ~{2{pk::C0}};
  logic [1:0] a = pk::X1 + pk::X2 + pk::X3 + pk::X5;
  logic [3:0] b = pk::X6 ^ pk::X8 ^ pk::X9 ^ {M1, M2[1:0]} ^ M3;
  logic       c = pk::X7;
  int         d = pk::X4;
endmodule
