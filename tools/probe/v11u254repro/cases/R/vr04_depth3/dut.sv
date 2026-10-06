// § procReplCountOwner254 (the count in a leaf instance's always block three levels down, and in a port connection of the middle instance)
package pk;
  parameter int N = 3;
  parameter int M = 2;
endpackage
module leaf import pk::*; (input logic clk, input logic [5:0] a, output logic [5:0] o);
  always_ff @(posedge clk) begin : p_l
    o <= a ^ {N{2'b10}};
  end
endmodule
module mid import pk::*; (input logic clk, output logic [5:0] o);
  leaf l (.clk(clk), .a({N{2'b01}}), .o(o));
endmodule
module top (input logic clk, output logic [5:0] o);
  mid m (.clk(clk), .o(o));
endmodule
