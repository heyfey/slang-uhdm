// W3 -- three instances created by a GENERATE FOR with DESCENDING N, so source
// order and N order disagree and the loop bodies are gen_blocks, not plain
// instantiations.
module top_w3_genloop;
  localparam int NS [3] = '{9, 25, 2};
  for (genvar gi = 0; gi < 3; gi++) begin : g
    rggen_or_reducer #(.WIDTH(2), .N(NS[gi])) u (.i_data(), .o_result());
  end
endmodule
