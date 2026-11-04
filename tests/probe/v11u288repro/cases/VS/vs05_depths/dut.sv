// § streamPartSelLazyName288 — a streaming part-select in a module instantiated twice two levels down and in a two-level generate
module leaf(input logic [7:0] i, output logic [7:0] o); assign o = {<< {i[3:0], i[7:4]}}; endmodule
module mid(input logic [7:0] i, output logic [7:0] o, o2);
  leaf l1(.i(i), .o(o));
  for (genvar a = 0; a < 1; a++) begin : ga
    for (genvar b = 0; b < 1; b++) begin : gb
      leaf l2(.i(i), .o(o2));
      logic [7:0] z; assign z = {<< 2 {i[a +: 2], i[7:2]}};
    end
  end
endmodule
module top(input logic [7:0] i, output logic [7:0] o, o2, o3, o4); mid m1(i, o, o2); mid m2(i, o3, o4); endmodule
