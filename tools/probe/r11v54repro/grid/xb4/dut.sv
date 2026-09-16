// xb4 - the LEAF half: cross-package leaves and literal leaves inside a KEPT concat
package pq;
  parameter logic [1:0] Q0 = 2'b10;
  parameter logic [1:0] Q1 = 2'b01;
endpackage

package pk;
  parameter logic [1:0] C0 = 2'b01;
  // W1: every leaf is CROSS-PACKAGE
  parameter logic [3:0] W1 = {pq::Q0, pq::Q1};
  // W2: cross-package leaf + literal
  parameter logic [3:0] W2 = {pq::Q0, 2'b11};
  // W3: local leaf + literal (the S9 shape)
  parameter logic [3:0] W3 = {C0, 2'b11};
  // W4: replication whose count is a local param read
  parameter logic [3:0] W4 = {2{C0}};
  // W5: replication whose count is a CROSS-PACKAGE read
  parameter logic [3:0] W5 = {2{pq::Q1}};
  // W6: concat under a binary op with a cross-package leaf
  parameter logic [3:0] W6 = {pq::Q0, C0} | 4'b0001;
endpackage

module top;
  logic [3:0] a = pk::W1 ^ pk::W2 ^ pk::W3 ^ pk::W4 ^ pk::W5 ^ pk::W6;
endmodule
