// xb6 - ONLY the cross-package replication: is the patch toward or away by the judge?
package pq;
  parameter logic [1:0] Q1 = 2'b01;
endpackage
package pk;
  parameter logic [3:0] W5 = {2{pq::Q1}};
endpackage
module top;
  logic [3:0] a = pk::W5;
endmodule
