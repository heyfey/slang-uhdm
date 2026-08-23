module oth2;
  logic [7:0] mpk [4];
  wire [63:0] w;
  genvar gv;
  case (1)
    1: begin : cg
      wire [63:0] cgw;
      assign cgw = $bits(mpk[1] & 8'h0F);      // L8 case-generate
    end
  endcase
  for (gv = 0; gv < 2; gv++) begin : og
    for (genvar gw2 = 0; gw2 < 2; gw2++) begin : ig
      wire [63:0] nw;
      assign nw = $bits(mpk[1] & 8'h0F);       // L13 nested generate
    end
  end
  generate
    begin : bare
      wire [63:0] bw;
      assign bw = $bits(mpk[1] & 8'h0F);       // L19 bare generate block
    end
  endgenerate
  assign w = $bits(mpk[1] & 8'h0F);            // L22 module top
endmodule
