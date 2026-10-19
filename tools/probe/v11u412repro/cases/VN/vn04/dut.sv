// § interconnectNetNone412
module top;
  for (genvar g = 0; g < 2; g++) begin : gb
    interconnect gi;
  end
  interconnect ia [1:0];
endmodule
