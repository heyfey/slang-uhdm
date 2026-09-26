// § externProtoFormalsFromPrototype175
package p;
  class k;
    extern task t(input bit [3:0] x,
                  output logic [7:0] y);
  endclass
  task k::t(input bit [3:0] x, output logic [7:0] y);
    y = {4'b0, x};
  endtask
endpackage
module top;
  import p::*;
  k o; logic [7:0] r;
  initial begin o = new; o.t(4'd3, r); end
endmodule
