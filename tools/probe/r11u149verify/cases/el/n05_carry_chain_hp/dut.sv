// § elabCloneInstTreeUnstored144 (--elabuhdm)
module dut(input logic [3:0] a, output logic y);
  for (genvar i = 0; i < 4; i++) begin : ST
    logic c;
    if (i == 0) begin : C
      assign c = a[0];
    end else begin : C
      assign c = ST[i - 1].c & a[i];
    end
  end
  assign y = ST[3].c;
endmodule
