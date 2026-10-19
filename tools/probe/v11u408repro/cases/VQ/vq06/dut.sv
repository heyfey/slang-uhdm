// § classBoundedQueueStatic408
package pk;
  parameter int P = 4;
endpackage
import pk::*;
class c;
  int q[$:P];
  int r[$:pk::P];
endclass
module top;
  c h;
  initial h = new;
endmodule
