// § procReplCountOwner254 (the replication count in a localparam initializer, a parameter default, a variable initializer and a named-block variable initializer)
package pk;
  parameter int N = 3;
  parameter int M = 2;
endpackage
module top import pk::*; #(parameter logic [5:0] D = {N{2'b10}}) (input logic clk, output logic [5:0] o, output logic [5:0] p);
  localparam logic [5:0] L = {N{2'b01}};
  logic [5:0] v = {N{2'b11}};
  always_ff @(posedge clk) begin : blk
    logic [5:0] t;
    t = {N{2'b10}};
    o <= t ^ L ^ v;
  end
  assign p = D;
endmodule
