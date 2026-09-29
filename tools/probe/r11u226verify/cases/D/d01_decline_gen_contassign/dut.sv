// § unsizedInnerSizeDeclines223 § sizeDeclineTsInvalid223v — $size of dynamic and queue inner dimensions in a continuous assignment (not a net initializer) and in a generate-block net initializer
module top(output logic [7:0] o1, output logic [7:0] o2);
  int md [4][];
  int mq [3][$];
  assign o1 = $size(md);
  if (1) begin : g
    wire [7:0] w = $size(mq, 1);
    assign o2 = w;
  end
endmodule
