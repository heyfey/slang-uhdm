// § rootPathElemOwnName181 § rootPathFullNameByChain181 § rootNetPathOwnNames181 (r11u190: $root paths as port actuals of an instance inside a generate-for and a generate-if scope, through two instance levels)
module leaf(input logic [3:0] a, output logic [3:0] y);
  assign y = a;
endmodule
module mid;
  logic [3:0] v;
  logic [3:0] w;
endmodule
module top;
  mid um();
  logic [3:0] o0, o1, o2;
  for (genvar g = 0; g < 2; g++) begin : G
    leaf u3(.a($root.top.um.v), .y());
  end
  if (1) begin : H
    leaf u4(.a($root.top.um.w), .y(o2));
  end
endmodule
