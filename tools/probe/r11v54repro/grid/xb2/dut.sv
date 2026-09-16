// xb2 - localparam / imported / cross-package / pattern-member concat
package pq;
  parameter logic [1:0] Q0 = 2'b10;
  parameter logic [3:0] QC = {Q0, 2'b01};
endpackage

package pk;
  import pq::*;
  parameter logic [1:0] C0 = 2'b01;
  localparam logic [1:0] C3 = 2'b11;
  // Y1: localparam whose Rhs is a concat of two package params
  localparam logic [3:0] Y1 = {C0, C3};
  // Y2: localparam whose Rhs is a replication under a cast
  localparam logic [3:0] Y2 = 4'({2{C0}});
  // Y3: cross-package concat
  parameter logic [3:0] Y3 = {pq::Q0, C0};
  // Y4: cross-package read of a param whose OWN Rhs is a concat
  parameter logic [3:0] Y4 = pq::QC;
  // Y5: cross-package read of a concat param, under a binary op
  parameter logic [3:0] Y5 = pq::QC + 4'd1;
  // Y6: struct pattern with a concat member
  typedef struct packed { logic [3:0] a; logic [1:0] b; } s_t;
  parameter s_t Y6 = '{a: {C0, C3}, b: C0};
  // Y7: concat of a concat
  parameter logic [5:0] Y7 = {{C0, C3}, C0};
  // Y8: plain read of a sibling (no concat) - must stay folded
  parameter logic [1:0] Y8 = C0;
endpackage

module top;
  import pk::*;
  logic [3:0] x = pk::Y1 ^ pk::Y2 ^ pk::Y3 ^ pk::Y4 ^ pk::Y5 ^ pk::Y7[3:0];
  logic [5:0] y = {pk::Y6.a, pk::Y6.b} ^ pk::Y7;
  logic [1:0] z = pk::Y8;
endmodule
