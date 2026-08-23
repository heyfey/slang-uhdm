package c01p;
  parameter PKB = 'b101;
  localparam PKL = 'h1a;
endpackage

interface c01i;
  parameter IFB = 'b101;
  localparam IFL = 'o17;
endinterface

program c01g;
  parameter PGB = 'b101;
endprogram

module c01m;
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi = gi + 1) begin : gb
      parameter GNB = 'b101;
      localparam GNL = 'h1a;
    end
  endgenerate
  if (1) begin : cb
    localparam CNB = 'b101;
  end
endmodule
