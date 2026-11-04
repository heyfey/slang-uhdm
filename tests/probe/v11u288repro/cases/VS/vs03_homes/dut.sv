// § streamPartSelLazyName288 — a streaming part-select in an interface, a task, a for-generate block, an if-generate block and a package task
package sp;
  task automatic pt(input logic [7:0] v, output logic [7:0] r); r = {<< {v[3:0], v[7:4]}}; endtask
endpackage
interface ifc(input logic [7:0] i); logic [7:0] q; assign q = {<< 2 {i[5:0], 2'b0}}; endinterface
module top #(parameter int N = 2)(input logic [7:0] i, output logic [7:0] o, o2, o3, output logic [7:0] g [N]);
  task automatic t(output logic [7:0] r); r = {<< {i[3:0], i[7:4]}}; endtask
  ifc u(i);
  for (genvar k = 0; k < N; k++) begin : gf
    assign g[k] = {<< {i[k +: 4], i[3:0]}};
  end
  if (N > 1) begin : gi
    always_comb o3 = {<< 4 {i[7:4], i[3:0]}};
  end
  always_comb begin t(o); sp::pt(i, o2); end
endmodule
