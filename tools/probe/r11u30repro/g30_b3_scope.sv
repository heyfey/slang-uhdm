// r11u30 arm b3 — the same open-range set in every SCOPE whose def and elab
// views are emitted by different routes: a package function, an interface, a
// generate block, a module instantiated TWICE (two elab copies of one def), a
// class method reached through a package, and a task called from an initial.
package pk30;
  localparam int PL30 = 3;
  function automatic bit pf30(int v30);
    return v30 inside {[1:PL30]};
  endfunction
  class cl30;
    int fv30;
    function bit cm30(int v30);
      return v30 inside {2, [4:6]};
    endfunction
  endclass
endpackage
interface if30 (input logic clk30);
  int iv30;
  function automatic bit ifn30(int v30);
    return v30 inside {[1:4]};
  endfunction
endinterface
module leaf30 #(parameter int W30 = 1) (input logic [3:0] d30, output logic q30);
  assign q30 = d30 inside {[4'd1:4'd6]};
  function automatic bit lf30(int v30);
    return v30 inside {W30, [2:3]};
  endfunction
endmodule
module top30 (input logic clk30, input logic [3:0] d30, output logic [1:0] q30);
  leaf30 #(.W30(1)) u1_30 (.d30(d30), .q30(q30[0]));
  leaf30 #(.W30(2)) u2_30 (.d30(d30), .q30(q30[1]));
  if30 i30 (.clk30(clk30));
  for (genvar g30 = 0; g30 < 2; g30++) begin : gb30
    logic gq30;
    always_comb gq30 = d30 inside {[4'd2:4'd5]};
  end
  int tv30;
  task automatic t30(int v30);
    if (v30 inside {1, [3:5]}) tv30 = v30;
  endtask
  initial t30(4);
endmodule
