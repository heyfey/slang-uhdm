// r10uvm99 arm a6: `inside` in an IMMEDIATE assertion and a CONCURRENT one.
module eta99 (input logic clk99, input int val99);
  always @(posedge clk99) begin
    assert (val99 inside {[1:5]}) else $error("bad");
  end
  property p_rng99;
    @(posedge clk99) val99 inside {[2:4]};
  endproperty
  a_rng99: assert property (p_rng99);
  a_dir99: assert property (@(posedge clk99) val99 inside {1, [3:6]});
endmodule
