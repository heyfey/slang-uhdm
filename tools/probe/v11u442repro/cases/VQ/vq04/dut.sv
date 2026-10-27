// § paramBoundQTd442
package p;
  parameter B = 4;
endpackage
module top;
  import p::*;
  typedef int q_t [$:B];
  q_t a;
endmodule
