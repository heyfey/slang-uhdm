package pk; parameter int unsigned ADDR_W = 32; parameter int unsigned IX = 8; parameter int unsigned IC_TAG_SIZE = ADDR_W - IX - 4 + 1; endpackage
module top import pk::*; (input logic [IC_TAG_SIZE-1:0] t [2], output logic [1:0] inv);
  for (genvar way = 0; way < 2; way++) begin : gen_tag_match
    assign inv[way] = ~t[way][IC_TAG_SIZE-1];
  end
endmodule
